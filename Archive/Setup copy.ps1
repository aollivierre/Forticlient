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
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$repoUrl = "https://github.com/aollivierre/Forticlient/archive/refs/heads/main.zip"
$zipPath = "$env:TEMP\Forticlient_$timestamp.zip"
$extractPath = "$env:TEMP\Forticlient_$timestamp"
$sevenZipUrl = "https://www.7-zip.org/a/7z2107-x64.msi"  # Update the URL if necessary
$sevenZipInstallerPath = "$env:TEMP\7z_$timestamp.msi"
$sevenZipExePath = "C:\Program Files\7-Zip\7z.exe"

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

# Function to download and install 7-Zip
function Install-7Zip {
    if (-Not (Test-Path $sevenZipExePath)) {
        Write-Host "Downloading 7-Zip installer..."
        Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipInstallerPath
        Write-Host "Installing 7-Zip..."
        Start-Process msiexec.exe -ArgumentList "/i", "`"$sevenZipInstallerPath`"", "/quiet", "/norestart" -Wait
        Write-Host "7-Zip installation complete."
    } else {
        Write-Host "7-Zip is already installed."
    }
}

# Function to extract all ZIP files recursively, including segmented ZIP files
function Extract-AllZips {
    param (
        [string]$rootPath
    )

    Write-Host "Extracting all ZIP files recursively..."
    $zipFiles = Get-ChildItem -Path $rootPath -Recurse -Include '*.zip.001'

    foreach ($zipFile in $zipFiles) {
        $baseName = $zipFile.BaseName -replace '\.zip\.001$', ''
        $destinationFolder = [System.IO.Path]::GetDirectoryName($zipFile.FullName)

        Write-Host "Combining and extracting segmented ZIP files for $baseName using 7-Zip..."
        
        # Use 7-Zip to extract segmented ZIP files
        $sevenZipCommand = "& `"$sevenZipExePath`" x `"$zipFile.FullName`" -o`"$destinationFolder`""
        Write-Host "Executing: $sevenZipCommand"
        Invoke-Expression $sevenZipCommand
    }

    Write-Host "All ZIP files extracted."
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
Install-7Zip
Extract-AllZips -rootPath $extractPath
Execute-Deployment
