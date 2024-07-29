function Ensure-ExportsFolder {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BasePath,
        [Parameter(Mandatory = $true)]
        [string]$ExportsFolderName,
        [Parameter(Mandatory = $true)]
        [string]$ExportSubFolderName
    )

    # Construct the full path to the exports folder
    $ExportsBaseFolderPath = Join-Path -Path $BasePath -ChildPath $ExportsFolderName
    $ExportsFolderPath = Join-Path -Path $ExportsBaseFolderPath -ChildPath $ExportSubFolderName

    # Check if the base exports folder exists
    if (-Not (Test-Path -Path $ExportsBaseFolderPath)) {
        # Create the base exports folder
        New-Item -ItemType Directory -Path $ExportsBaseFolderPath | Out-Null
        Write-EnhancedLog -Message "Created base exports folder at: $ExportsBaseFolderPath" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
    }


    if (-Not (Test-Path -Path $ExportsFolderPath)) {
        # Create the base exports folder
        New-Item -ItemType Directory -Path $ExportsFolderPath | Out-Null
        Write-EnhancedLog -Message "Created base exports folder at: $ExportsFolderPath" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
    }

    # Ensure the subfolder is clean
    Clean-ExportsFolder -FolderPath $ExportsFolderPath

    # Return the full path of the exports folder
    return $ExportsFolderPath
}