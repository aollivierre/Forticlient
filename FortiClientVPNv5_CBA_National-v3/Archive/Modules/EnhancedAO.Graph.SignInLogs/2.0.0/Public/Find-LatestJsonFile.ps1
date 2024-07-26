# Function to find the latest JSON file in the specified directory
function Find-LatestJsonFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Directory
    )

    $jsonFiles = Get-ChildItem -Path $Directory -Filter *.json | Sort-Object LastWriteTime -Descending

    if ($jsonFiles.Count -gt 0) {
        return $jsonFiles[0].FullName
    } else {
        Write-EnhancedLog -Message "No JSON files found in $Directory." -Level "ERROR"
        # return $null
    }
}


