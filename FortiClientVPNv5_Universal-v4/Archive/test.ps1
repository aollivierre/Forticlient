# Variables
$GithubRepository = 'PSAppDeployToolkit/PSAppDeployToolkit'
$FilenamePatternMatch = '*.zip'
$ScriptDirectory = 'C:\code\Forticlient\FortiClientVPNv5_Universal-v4'
$excludeFile = 'deploy-application.ps1'

# Temporary paths
$tempPath = [System.IO.Path]::GetTempPath()
$zipTempDownloadPath = Join-Path -Path $tempPath -ChildPath 'PSAppDeployToolkit.zip'
$tempExtractionPath = Join-Path -Path $tempPath -ChildPath 'PSAppDeployToolkit'

# GitHub API URL
$psadtReleaseUri = "https://api.github.com/repos/$GithubRepository/releases/latest"

try {
    # Fetch the latest release information from GitHub
    Write-Host "Fetching the latest release information from GitHub" -ForegroundColor Green
    $psadtDownloadUri = (Invoke-RestMethod -Method GET -Uri $psadtReleaseUri).assets |
        Where-Object { $_.name -like $FilenamePatternMatch } |
        Select-Object -ExpandProperty browser_download_url

    if (-not $psadtDownloadUri) {
        throw "No matching file found for pattern: $FilenamePatternMatch"
    }
    Write-Host "Found matching download URL: $psadtDownloadUri" -ForegroundColor Green

    # Download the file to the temporary location
    Write-Host "Downloading file from $psadtDownloadUri to $zipTempDownloadPath" -ForegroundColor Green
    Invoke-WebRequest -Uri $psadtDownloadUri -OutFile $zipTempDownloadPath

    # Unblock the downloaded file if necessary
    Write-Host "Unblocking file at $zipTempDownloadPath" -ForegroundColor Green
    Unblock-File -Path $zipTempDownloadPath

    # Extract the contents of the zip file to the temporary extraction path
    if (-not (Test-Path $tempExtractionPath)) {
        New-Item -Path $tempExtractionPath -ItemType Directory | Out-Null
    }
    Write-Host "Extracting file from $zipTempDownloadPath to $tempExtractionPath" -ForegroundColor Green
    Expand-Archive -Path $zipTempDownloadPath -DestinationPath $tempExtractionPath -Force

    # Ensure the destination directory exists
    if (-not (Test-Path $ScriptDirectory)) {
        New-Item -Path $ScriptDirectory -ItemType Directory | Out-Null
    }

    # Use robocopy to copy files, excluding the specified file
    $robocopyArgs = @(
        $tempExtractionPath,
        $ScriptDirectory,
        "/E", # Copies subdirectories, including empty ones
        "/XF", # Excludes specified files
        $excludeFile
    )

    # Execute robocopy
    $robocopyCommand = "robocopy.exe $($robocopyArgs -join ' ')"
    Write-Host "Executing: $robocopyCommand" -ForegroundColor Green
    Invoke-Expression $robocopyCommand

    Write-Host "Files copied successfully to $ScriptDirectory" -ForegroundColor Green

    # Clean up temporary files
    Write-Host "Removing temporary download file: $zipTempDownloadPath" -ForegroundColor Green
    Remove-Item -Path $zipTempDownloadPath -Force

    Write-Host "Removing temporary extraction folder: $tempExtractionPath" -ForegroundColor Green
    Remove-Item -Path $tempExtractionPath -Recurse -Force

} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
