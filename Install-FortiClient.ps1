# Initialize the global steps list
$global:steps = [System.Collections.Generic.List[PSCustomObject]]::new()
$global:currentStep = 0

# Function to check if running as administrator
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Set-ExecutionPolicyBypass {
    [CmdletBinding()]
    param (
        [string]$Scope = "Process"  # Default scope is "Process" for the current session
    )

    try {
        Write-Host "Setting execution policy to Bypass for scope: $Scope" -ForegroundColor Cyan
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope $Scope -Force
        Write-Host "Execution policy successfully set to Bypass." -ForegroundColor Green
    }
    catch {
        Write-Host "Error setting execution policy: $($_.Exception.Message)" -ForegroundColor Red
        throw $_
    }
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

# # Function to download files with retry logic
# function Start-BitsTransferWithRetry {
#     param (
#         [string]$Source,
#         [string]$Destination,
#         [int]$MaxRetries = 3
#     )
#     $attempt = 0
#     $success = $false

#     while ($attempt -lt $MaxRetries -and -not $success) {
#         try {
#             $attempt++
#             if (-not (Test-Path -Path (Split-Path $Destination -Parent))) {
#                 throw "Destination path does not exist: $(Split-Path $Destination -Parent)"
#             }
#             $bitsTransferParams = @{
#                 Source      = $Source
#                 Destination = $Destination
#                 ErrorAction = "Stop"
#             }
#             Start-BitsTransfer @bitsTransferParams
#             $success = $true
#         }
#         catch {
#             Write-Log "Attempt $attempt failed: $_" -Level "ERROR"
#             if ($attempt -eq $MaxRetries) {
#                 throw "Maximum retry attempts reached. Download failed."
#             }
#             Start-Sleep -Seconds 5
#         }
#     }
# }

# Function to validate the installation of FortiClient VPN
function Validate-FortiClientVPNInstallation {
    param (
        [string[]]$RegistryPaths,
        [string]$SoftwareName = "*FortiClient*",
        [version]$MinVersion = [version]"7.4.0.1658"
    )

    foreach ($path in $RegistryPaths) {
        if (-not (Test-Path $path)) {
            Write-Log "Registry path not found: $path" -Level "ERROR"
            continue
        }

        $items = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            $app = Get-ItemProperty -Path $item.PsPath -ErrorAction SilentlyContinue
            if ($app.DisplayName -like $SoftwareName) {
                $installedVersion = [version]$app.DisplayVersion
                if ($installedVersion -ge $MinVersion) {
                    return @{
                        IsInstalled = $true
                        Version     = $installedVersion
                        ProductCode = $app.PSChildName
                    }
                }
            }
        }
    }

    return @{ IsInstalled = $false }
}





# Function to download Forticlient repository from GitHub using WebClient with retry mechanism
function Download-ForticlientRepo {
    param (
        [string]$repoUrl = "https://github.com/aollivierre/Forticlient/archive/refs/heads/main.zip",
        [string]$destinationFolder = "$env:TEMP",
        [int]$MaxRetries = 3,
        [int]$DelayBetweenRetries = 5 # Delay in seconds
    )

    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $zipPath = "$destinationFolder\Forticlient_$timestamp.zip"
    $extractPath = "$destinationFolder\Forticlient_$timestamp"

    # Validate paths
    if (-not (Test-Path -Path $destinationFolder)) {
        Write-Log "Destination folder path not found: $destinationFolder" -Level "ERROR"
        throw "Destination folder path does not exist: $destinationFolder"
    }

    Write-Log "Starting download of Forticlient repository from $repoUrl to $zipPath..."

    $attempt = 0
    $success = $false

    while ($attempt -lt $MaxRetries -and -not $success) {
        try {
            $attempt++
            Write-Log "Attempt $attempt of downloading the repository..."
            
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($repoUrl, $zipPath)

            if (-not (Test-Path -Path $zipPath)) {
                throw "Download failed: The file was not created at $zipPath"
            }

            Write-Log "Download complete: The repository has been successfully downloaded to $zipPath." -Level "INFO"
            $success = $true

            return $zipPath, $extractPath
        }
        catch {
            Write-Log "Attempt $attempt failed: $_" -Level "ERROR"
            if ($attempt -lt $MaxRetries) {
                Write-Log "Retrying in $DelayBetweenRetries seconds..." -Level "WARNING"
                Start-Sleep -Seconds $DelayBetweenRetries
            }
            else {
                Write-Log "Maximum retry attempts reached. Download failed." -Level "ERROR"
                throw "Maximum retry attempts reached. Download failed."
            }
        }
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

    # Validate that the extractPath exists
    if (-not (Test-Path -Path $extractPath)) {
        Write-Log "The specified extract path does not exist: $extractPath" -Level "ERROR"
        throw "The extract path does not exist: $extractPath"
    }

    Write-Log "Searching for folder matching pattern '$folderPattern' in $extractPath..." -Level "INFO"
    $deployFolder = Get-ChildItem -Path $extractPath -Recurse -Directory | Where-Object { $_.Name -like $folderPattern }
    
    if ($deployFolder) {
        Write-Log "Folder found: $($deployFolder.FullName). Searching for script '$scriptName'..." -Level "INFO"
        $scriptPath = Get-ChildItem -Path $deployFolder.FullName -Recurse -Filter $scriptName | Select-Object -First 1
        
        if ($scriptPath) {
            Write-Log "Script found: $($scriptPath.FullName). Preparing to execute in a new PowerShell instance..." -Level "INFO"
            
            # Get PowerShell path
            $powerShellPath = Get-PowerShellPath

            # Splatting parameters for Start-Process
            $startProcessParams = @{
                FilePath     = $powerShellPath
                ArgumentList = @("-NoExit", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$scriptPath`"")
                Wait         = $true
            }

            try {
                Start-Process @startProcessParams
                Write-Log "$scriptName execution complete." -Level "INFO"
            }
            catch {
                Write-Log "An error occurred while executing the script: $_" -Level "ERROR"
                throw
            }
        }
        else {
            Write-Log "$scriptName not found in the repository under folder: $($deployFolder.FullName)." -Level "ERROR"
        }
    }
    else {
        Write-Log "No folder found with name containing '$folderPattern' in $extractPath." -Level "ERROR"
    }
}



# Add all your steps here
Add-Step "Starting pre-installation validation for FortiClientVPN"
Add-Step "Downloading Forticlient repository from GitHub"
Add-Step "Extracting Forticlient repository"
Add-Step "Extracting all ZIP files recursively"
Add-Step "Executing Uninstall.ps1 script"
Add-Step "Executing Scheduler.ps1 script"
Add-Step "Starting post-installation validation for FortiClientVPN"

# Calculate the total number of steps after all steps are added
$totalSteps = $global:steps.Count



# Main Script Execution
try {
    Test-Admin

    # Set the execution policy to Bypass
    Set-ExecutionPolicyBypass

    Log-Step
    Write-Log "Starting pre-installation validation for FortiClientVPN..." -Level "INFO"
    $preValidationResult = Validate-FortiClientVPNInstallation -RegistryPaths $registryPaths

    if ($preValidationResult.IsInstalled) {
        Write-Log "FortiClientVPN version $($preValidationResult.Version) is installed and meets the minimum version requirement." -Level "INFO"
        $installationResults.Add([pscustomobject]@{ SoftwareName = "FortiClientVPN"; Status = "Pre-installed"; VersionFound = $preValidationResult.Version })
    }
    else {
        Write-Log "FortiClientVPN version 7.4.0.1658 or newer is not installed. Proceeding with installation steps." -Level "INFO"

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

        Log-Step
        Write-Log "Starting post-installation validation for FortiClientVPN..." -Level "INFO"
        $postValidationResult = Validate-FortiClientVPNInstallation -RegistryPaths $registryPaths

        if ($postValidationResult.IsInstalled) {
            Write-Log "Post-installation validation successful: FortiClientVPN version $($postValidationResult.Version) is installed." -Level "INFO"
            $installationResults.Add([pscustomobject]@{ SoftwareName = "FortiClientVPN"; Status = "Successfully Installed"; VersionFound = $postValidationResult.Version })
        }
        else {
            Write-Log "Post-installation validation failed: FortiClientVPN was not found or does not meet the minimum version requirement." -Level "ERROR"
            $installationResults.Add([pscustomobject]@{ SoftwareName = "FortiClientVPN"; Status = "Failed - Not Found After Installation"; VersionFound = "N/A" })
        }
    }

    # Summary report
    Write-Host "Installation Summary:" -ForegroundColor Cyan
    $installationResults | ForEach-Object {
        Write-Host "Software: $($_.SoftwareName)" -ForegroundColor White
        Write-Host "Status: $($_.Status)" -ForegroundColor White
        Write-Host "Version Found: $($_.VersionFound)" -ForegroundColor White
        Write-Host "----------------------------------------" -ForegroundColor Gray
    }
}
catch {
    Write-Log "An error occurred: $_" -Level "ERROR"
    throw
}
