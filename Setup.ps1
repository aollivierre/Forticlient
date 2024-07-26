#call using powershell -Command "iex (irm https://raw.githubusercontent.com/aollivierre/Forticlient/main/Forticlient.ps1)"
#call using powershell -Command "iex (irm https://bit.ly/3WE7AE9)"

# Initialize the global steps list
$global:steps = [System.Collections.Generic.List[PSCustomObject]]::new()
$global:currentStep = 0

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
    Write-Host "Step [$global:currentStep/$totalSteps]: $stepDescription"
}

# Define the steps before execution
Add-Step "Fetching the latest 7-Zip release info"
Add-Step "Finding the MSI asset URL"
Add-Step "Downloading the MSI file"
Add-Step "Installing 7-Zip"
Add-Step "Downloading Forticlient repository from GitHub"
Add-Step "Extracting Forticlient repository"
Add-Step "Extracting all ZIP files recursively"
Add-Step "Executing Uninstall.ps1 script"

# Calculate total steps dynamically
$totalSteps = $global:steps.Count

# Main script execution with try-catch for error handling
try {
    # Step 1: Fetching the latest 7-Zip release info
    Log-Step
    $releaseUrl = 'https://api.github.com/repos/ip7z/7zip/releases/latest'
    $releaseInfo = Invoke-RestMethod -Uri $releaseUrl

    # Step 2: Finding the MSI asset URL
    Log-Step
    $msiAssets = $releaseInfo.assets | Where-Object { $_.name -like '*.msi' }
    if (-not $msiAssets) {
        throw "7-Zip MSI installer not found in the latest release."
    }

    # Select the appropriate MSI asset (e.g., prefer x64 over x86)
    $msiAsset = $msiAssets | Where-Object { $_.name -like '*x64.msi' } | Select-Object -First 1
    if (-not $msiAsset) {
        $msiAsset = $msiAssets | Select-Object -First 1
    }

    $msiUrl = $msiAsset.browser_download_url
    Write-Host "Found MSI asset URL: $msiUrl"

    # Step 3: Downloading the MSI file
    Log-Step
    $msiPath = "$env:TEMP\7z_latest.msi"
    Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath
    Write-Host "Downloaded MSI file to $msiPath"
    
    # Step 4: Installing 7-Zip
    Log-Step
    Start-Process msiexec.exe -ArgumentList "/i", "`"$msiPath`"", "/quiet", "/norestart" -Wait
    Write-Host "7-Zip installation complete."

    # Step 5: Downloading Forticlient repository from GitHub
    Log-Step
    $repoUrl = "https://github.com/aollivierre/Forticlient/archive/refs/heads/main.zip"
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $zipPath = "$env:TEMP\Forticlient_$timestamp.zip"
    $extractPath = "$env:TEMP\Forticlient_$timestamp"
    Write-Host "Downloading Forticlient repository from GitHub..."
    Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath
    Write-Host "Download complete."

    # Step 6: Extracting Forticlient repository
    Log-Step
    Write-Host "Extracting Forticlient repository..."
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    Write-Host "Extraction complete."

    # Step 7: Extracting all ZIP files recursively
    Log-Step
    Write-Host "Extracting all ZIP files recursively..."
    $zipFiles = Get-ChildItem -Path $extractPath -Recurse -Include '*.zip.001'
    foreach ($zipFile in $zipFiles) {
        $destinationFolder = [System.IO.Path]::GetDirectoryName($zipFile.FullName)
        Write-Host "Combining and extracting segmented ZIP files for $($zipFile.BaseName) using 7-Zip..."
        $sevenZipCommand = "& `"$env:ProgramFiles\7-Zip\7z.exe`" x `"$zipFile`" -o`"$destinationFolder`""
        Write-Host "Executing: $sevenZipCommand"
        Invoke-Expression $sevenZipCommand
    }
    Write-Host "All ZIP files extracted."

    # Step 8: Executing Uninstall.ps1 script
    Log-Step
    $deployFolder = Get-ChildItem -Path $extractPath -Recurse -Directory | Where-Object { $_.Name -like '*FortiClientEMS*' }
    if ($deployFolder) {
        $uninstallScript = Get-ChildItem -Path $deployFolder.FullName -Recurse -Filter 'Uninstall.ps1' | Select-Object -First 1
        if ($uninstallScript) {
            Write-Host "Executing Uninstall.ps1..."
            & powershell.exe -File $uninstallScript.FullName -Wait
            Write-Host "Uninstall.ps1 execution complete."
        } else {
            Write-Error "Uninstall.ps1 not found."
        }
    } else {
        Write-Error "No folder found with name containing 'FortiClientEMS'."
    }
} catch {
    # Capture the error details
    $errorDetails = $_ | Out-String
    Write-Host "An error occurred: $errorDetails" -ForegroundColor Red
    throw
}
