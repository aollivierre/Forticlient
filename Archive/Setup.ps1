<#
.SYNOPSIS
    Forticlient Deployment Script
.DESCRIPTION
    This script downloads the Forticlient project from GitHub, extracts it, and executes deploy-application.exe
.NOTES
    Requires Windows 10 or higher
.LINK
    https://github.com/aollivierre/Forticlient
.EXAMPLE
    powershell iex(irm https://raw.githubusercontent.com/aollivierre/Forticlient/main/Forticlient.ps1)
#>

# Define variables
$repoUrl = "https://github.com/aollivierre/Forticlient/archive/refs/heads/main.zip"
$zipPath = "$env:TEMP\Forticlient.zip"
$extractPath = "$env:TEMP\Forticlient"

# Function to download the repository
function Download-Repo {
    Write-Host "Downloading Forticlient repository from GitHub..."
    Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath
    Write-Host "Download complete."
}

# Function to extract the ZIP file
function Extract-Repo {
    Write-Host "Extracting Forticlient repository..."
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    Write-Host "Extraction complete."
}

# Function to execute deploy-application.exe
function Execute-Deployment {
    $deployExe = "$extractPath\Forticlient-main\deploy-application.exe"
    if (Test-Path $deployExe) {
        Write-Host "Executing deploy-application.exe..."
        Start-Process $deployExe -Wait
        Write-Host "Execution complete."
    } else {
        Write-Error "deploy-application.exe not found."
    }
}

# Main script execution
Download-Repo
Extract-Repo
# Execute-Deployment
