# Function to check if running as administrator
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function for logging with color coding
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "INFO" { Write-Host $logMessage -ForegroundColor Green }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        default { Write-Host $logMessage -ForegroundColor White }
    }

    # Append to log file
    $logFilePath = [System.IO.Path]::Combine($env:TEMP, 'install-VCppRedist.log')
    $logMessage | Out-File -FilePath $logFilePath -Append -Encoding utf8
}

# Function to add steps
function Add-Step {
    param (
        [string]$description
    )
    $global:steps.Add([PSCustomObject]@{ Description = $description })
}

# Function to log the current step
function Log-Step {
    $global:currentStep++
    $totalSteps = $global:steps.Count
    $stepDescription = $global:steps[$global:currentStep - 1].Description
    Write-Log "Step [$global:currentStep/$totalSteps]: $stepDescription" -Level "INFO"
}

# Function to download files with retry logic
function Start-BitsTransferWithRetry {
    param (
        [string]$Source,
        [string]$Destination,
        [int]$MaxRetries = 3
    )
    $attempt = 0
    $success = $false

    while ($attempt -lt $MaxRetries -and -not $success) {
        try {
            $attempt++
            if (-not (Test-Path -Path (Split-Path $Destination -Parent))) {
                throw "Destination path does not exist: $(Split-Path $Destination -Parent)"
            }
            $bitsTransferParams = @{
                Source      = $Source
                Destination = $Destination
                ErrorAction = "Stop"
            }
            Start-BitsTransfer @bitsTransferParams
            $success = $true
        }
        catch {
            Write-Log "Attempt $attempt failed: $_" -Level "ERROR"
            if ($attempt -eq $MaxRetries) {
                throw "Maximum retry attempts reached. Download failed."
            }
            Start-Sleep -Seconds 5
        }
    }
}

# Function to validate the installation of Visual C++ Redistributable
function Validate-VCppRedistInstallation {
    param (
        [Parameter(Mandatory = $true)]
        [string]$arch,
        
        [version]$MinVersion = [version]"14.40.33810.0",
        
        [int]$MaxRetries = 3,
        
        [int]$DelayBetweenRetries = 5
    )

    $retryCount = 0
    $validationSucceeded = $false
    $registryPath = "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\$arch"
    $foundVersion = $null

    # Check standard path first
    if (Test-Path $registryPath) {
        $app = Get-ItemProperty -Path $registryPath
        # Remove the leading 'v' if present before parsing
        $installedVersionString = $app.Version -replace '^v', ''
        $installedVersion = [version]$installedVersionString
        $foundVersion = $installedVersion
        Write-Log "Found Visual C++ Redistributable ($arch) version $installedVersion." -Level "INFO"
        if ($installedVersion -ge $MinVersion) {
            Write-Log "Visual C++ Redistributable ($arch) version $installedVersion meets the minimum version requirement ($MinVersion)." -Level "INFO"
            return @{
                IsInstalled = $true
                Version     = $installedVersion
            }
        }
        else {
            Write-Log "Visual C++ Redistributable ($arch) version $installedVersion does not meet the minimum version requirement ($MinVersion)." -Level "WARNING"
            # No need to retry if the version is already found and not meeting the minimum
            return @{
                IsInstalled = $false
                Version     = $installedVersion
            }
        }
    } 
    # Check WOW6432Node path for x86 specifically
    elseif ($arch -eq "x86" -and (Test-Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\$arch")) {
        $app = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\$arch"
        # Remove the leading 'v' if present before parsing
        $installedVersionString = $app.Version -replace '^v', ''
        $installedVersion = [version]$installedVersionString
        $foundVersion = $installedVersion
        Write-Log "Found Visual C++ Redistributable ($arch) version $installedVersion." -Level "INFO"
        if ($installedVersion -ge $MinVersion) {
            Write-Log "Visual C++ Redistributable ($arch) version $installedVersion meets the minimum version requirement ($MinVersion)." -Level "INFO"
            return @{
                IsInstalled = $true
                Version     = $installedVersion
            }
        }
        else {
            Write-Log "Visual C++ Redistributable ($arch) version $installedVersion does not meet the minimum version requirement ($MinVersion)." -Level "WARNING"
            # No need to retry if the version is already found and not meeting the minimum
            return @{
                IsInstalled = $false
                Version     = $installedVersion
            }
        }
    }
    else {
        # If the path doesn't exist, no need to retry
        Write-Log "Visual C++ Redistributable ($arch) is not currently installed or does not meet the minimum version requirement." -Level "INFO"
        return @{
            IsInstalled = $false
        }
    }

    # ... (rest of the logic)
}



# Function to download Forticlient repository from GitHub
function Download-ForticlientRepo {
    param (
        [string]$repoUrl = "https://github.com/aollivierre/Forticlient/archive/refs/heads/main.zip",
        [string]$destinationFolder = "$env:TEMP"
    )

    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $zipPath = "$destinationFolder\Forticlient_$timestamp.zip"
    $extractPath = "$destinationFolder\Forticlient_$timestamp"

    Write-Log "Downloading Forticlient repository from GitHub..."
    try {
        Start-BitsTransferWithRetry -Source $repoUrl -Destination $zipPath
        Write-Log "Download complete: The repository has been downloaded to $zipPath." -Level "INFO"
        return $zipPath, $extractPath
    }
    catch {
        Write-Log "Error downloading Forticlient repository: $_" -Level "ERROR"
        throw
    }
}

# Function to extract the downloaded Forticlient repository
function Extract-ForticlientRepo {
    param (
        [string]$zipPath,
        [string]$extractPath
    )

    Write-Log "Extracting Forticlient repository..."
    try {
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
        Write-Log "Extraction complete: Repository extracted to $extractPath." -Level "INFO"
    }
    catch {
        Write-Log "Error extracting Forticlient repository: $_" -Level "ERROR"
        throw
    }
}

# Function to recursively extract all segmented ZIP files using 7-Zip
function Extract-AllZipFilesRecursively {
    param (
        [string]$extractPath
    )

    Write-Log "Extracting all ZIP files recursively..."
    try {
        $zipFiles = Get-ChildItem -Path $extractPath -Recurse -Include '*.zip.001'
        foreach ($zipFile in $zipFiles) {
            $destinationFolder = [System.IO.Path]::GetDirectoryName($zipFile.FullName)
            Write-Log "Combining and extracting segmented ZIP files for $($zipFile.BaseName) using 7-Zip..."
            $sevenZipCommand = "& `"$env:ProgramFiles\7-Zip\7z.exe`" x `"$zipFile`" -o`"$destinationFolder`""
            Write-Log "Executing: $sevenZipCommand"
            Invoke-Expression $sevenZipCommand
        }
        Write-Log "All ZIP files extracted successfully." -Level "INFO"
    }
    catch {
        Write-Log "Error extracting ZIP files: $_" -Level "ERROR"
        throw
    }
}


# Function to get PowerShell path
function Get-PowerShellPath {
    if (Test-Path "C:\Program Files\PowerShell\7\pwsh.exe") {
        return "C:\Program Files\PowerShell\7\pwsh.exe"
    }
    elseif (Test-Path "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe") {
        return "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    }
    else {
        throw "Neither PowerShell 7 nor PowerShell 5 was found on this system."
    }
}

# Function to execute a PowerShell script from the extracted repository


function Execute-Script {
    param (
        [string]$extractPath,
        [string]$folderPattern,
        [string]$scriptName
    )

    Log-Step
    $deployFolder = Get-ChildItem -Path $extractPath -Recurse -Directory | Where-Object { $_.Name -like $folderPattern }
    if ($deployFolder) {
        $scriptPath = Get-ChildItem -Path $deployFolder.FullName -Recurse -Filter $scriptName | Select-Object -First 1
        if ($scriptPath) {
            Write-Log "Executing $scriptName..."
            
            # Get PowerShell path
            $powerShellPath = Get-PowerShellPath

            # Splatting parameters
            $startProcessParams = @{
                FilePath     = $powerShellPath
                ArgumentList = @("-NoExit", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$scriptPath.FullName`"")
                Verb         = "RunAs"
                PassThru     = $true
                Wait         = $true
            }

            # Start the PowerShell process
            $process = Start-Process @startProcessParams
            Write-Log "$scriptName execution complete." -Level "INFO"
        }
        else {
            Write-Log "$scriptName not found in the repository." -Level "ERROR"
        }
    }
    else {
        Write-Log "No folder found with name containing '$folderPattern'." -Level "ERROR"
    }
}



try {
    Log-Step
    $zipPath, $extractPath = Download-ForticlientRepo

    Log-Step
    Extract-ForticlientRepo -zipPath $zipPath -extractPath $extractPath

    Log-Step
    Extract-AllZipFilesRecursively -extractPath $extractPath

    Log-Step
    Execute-Script -extractPath $extractPath -folderPattern '*FortiClientEMS*' -scriptName 'Uninstall.ps1'

    Log-Step
    Execute-Script -extractPath $extractPath -folderPattern '*FortiClientVPN*' -scriptName 'Scheduler.ps1'

}
catch {
    Write-Log "An error occurred: $_" -Level "ERROR"
    throw
}