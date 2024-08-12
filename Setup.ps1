# Initialize the global steps list
$global:steps = [System.Collections.Generic.List[PSCustomObject]]::new()
$global:currentStep = 0
$processList = [System.Collections.Generic.List[System.Diagnostics.Process]]::new()
$installationResults = [System.Collections.Generic.List[PSCustomObject]]::new()

# Function to add a step
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
    Write-Host "Step [$global:currentStep/$totalSteps]: $stepDescription" -ForegroundColor Cyan
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
    $logFilePath = [System.IO.Path]::Combine($env:TEMP, 'install-scripts.log')
    $logMessage | Out-File -FilePath $logFilePath -Append -Encoding utf8
}

# Function to validate URL
function Test-Url {
    param (
        [string]$url
    )
    try {
        Invoke-RestMethod -Uri $url -Method Head -ErrorAction Stop
        return $true
    }
    catch {
        return $false
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


# Function to validate software installation via registry with retry mechanism

function Validate-Installation {
    param (
        [string]$SoftwareName,
        [version]$MinVersion = [version]"0.0.0.0",
        [string]$RegistryPath = "",
        [int]$MaxRetries = 3,
        [int]$DelayBetweenRetries = 5  # Delay in seconds
    )

    # Skip validation for Visual C++ Redistributable as it has its own validation logic
    if ($SoftwareName -eq "Visual C++ Redistributable") {
        return @{ IsInstalled = $false }  # Force the script to always run
    }

    $retryCount = 0
    $validationSucceeded = $false

    while ($retryCount -lt $MaxRetries -and -not $validationSucceeded) {
        $registryPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"  # Include HKCU for user-installed apps
        )

        if ($RegistryPath) {
            # If a specific registry path is provided, check only that path
            if (Test-Path $RegistryPath) {
                $app = Get-ItemProperty -Path $RegistryPath -ErrorAction SilentlyContinue
                if ($app -and $app.DisplayName -like "*$SoftwareName*") {
                    $installedVersion = [version]$app.DisplayVersion
                    if ($installedVersion -ge $MinVersion) {
                        $validationSucceeded = $true
                        return @{
                            IsInstalled = $true
                            Version     = $installedVersion
                            ProductCode = $app.PSChildName
                        }
                    }
                }
            }
        } else {
            # If no specific registry path, check standard locations
            foreach ($path in $registryPaths) {
                $items = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
                foreach ($item in $items) {
                    $app = Get-ItemProperty -Path $item.PsPath -ErrorAction SilentlyContinue
                    if ($app.DisplayName -like "*$SoftwareName*") {
                        $installedVersion = [version]$app.DisplayVersion
                        if ($installedVersion -ge $MinVersion) {
                            $validationSucceeded = $true
                            return @{
                                IsInstalled = $true
                                Version     = $installedVersion
                                ProductCode = $app.PSChildName
                            }
                        }
                    }
                }
            }
        }

        $retryCount++
        if (-not $validationSucceeded) {
            Write-Log "Validation attempt $retryCount failed: $SoftwareName not found or version does not meet minimum requirements. Retrying in $DelayBetweenRetries seconds..." -Level "WARNING"
            Start-Sleep -Seconds $DelayBetweenRetries
        }
    }

    return @{ IsInstalled = $false }
}





# Define the GitHub URLs of the scripts and corresponding software names
$scriptDetails = @(
    @{ Url = "https://raw.githubusercontent.com/aollivierre/setuplab/main/Install-7zip.ps1"; SoftwareName = "7-Zip"; MinVersion = [version]"24.07.0.0" },
    @{ Url = "https://raw.githubusercontent.com/aollivierre/setuplab/main/Install-VCppRedist.ps1"; SoftwareName = "Visual C++ Redistributable"; MinVersion = [version]"14.40.33810.0" },
    @{ Url = "https://raw.githubusercontent.com/aollivierre/Forticlient/main/Install-FortiClient.ps1"; SoftwareName = "FortiClient VPN"; MinVersion = [version]"7.4.0.1658" }
)


# Add steps for each script
foreach ($detail in $scriptDetails) {
    Add-Step ("Running script from URL: $($detail.Url)")
}

# Define additional steps
Add-Step "Downloading Forticlient repository from GitHub"
Add-Step "Extracting Forticlient repository"
Add-Step "Extracting all ZIP files recursively"
Add-Step "Executing Uninstall.ps1 script"
Add-Step "Executing Scheduler.ps1 script"


# Main script execution with try-catch for error handling
try {
    $powerShellPath = Get-PowerShellPath

    foreach ($detail in $scriptDetails) {
        $url = $detail.Url
        $softwareName = $detail.SoftwareName
        $minVersion = $detail.MinVersion
        $registryPath = $detail.RegistryPath  # Directly extract RegistryPath

        # Validate before running the installation script
        Write-Log "Validating existing installation of $softwareName..."

        # Pass RegistryPath if it's available
        $installationCheck = if ($registryPath) {
            Validate-Installation -SoftwareName $softwareName -MinVersion $minVersion -MaxRetries 3 -DelayBetweenRetries 5 -RegistryPath $registryPath
        } else {
            Validate-Installation -SoftwareName $softwareName -MinVersion $minVersion -MaxRetries 3 -DelayBetweenRetries 5
        }

        if ($installationCheck.IsInstalled) {
            Write-Log "$softwareName version $($installationCheck.Version) is already installed. Skipping installation." -Level "INFO"
            $installationResults.Add([pscustomobject]@{ SoftwareName = $softwareName; Status = "Already Installed"; VersionFound = $installationCheck.Version })
        } else {
            if (Test-Url -url $url) {
                Log-Step
                Write-Log "Running script from URL: $url" -Level "INFO"
                $process = Start-Process -FilePath $powerShellPath -ArgumentList @("-NoExit", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", "Invoke-Expression (Invoke-RestMethod -Uri '$url')") -Verb RunAs -PassThru
                $processList.Add($process)

                $installationResults.Add([pscustomobject]@{ SoftwareName = $softwareName; Status = "Installed"; VersionFound = "N/A" })
            } else {
                Write-Log "URL $url is not accessible" -Level "ERROR"
                $installationResults.Add([pscustomobject]@{ SoftwareName = $softwareName; Status = "Failed - URL Not Accessible"; VersionFound = "N/A" })
            }
        }
    }

 

    # Wait for all processes to complete
    foreach ($process in $processList) {
        $process.WaitForExit()
    }

    # Post-installation validation and summary report (existing code continues here...)
    
} catch {
    # Capture the error details
    $errorDetails = $_ | Out-String
    Write-Log "An error occurred: $errorDetails" -Level "ERROR"
    throw
}


# Keep the PowerShell window open to review the logs
Read-Host 'Press Enter to close this window...'