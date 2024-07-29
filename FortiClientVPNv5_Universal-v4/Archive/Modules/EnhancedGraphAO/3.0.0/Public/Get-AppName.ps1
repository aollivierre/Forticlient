# Function to read the application name from app.json and append a timestamp
function Get-AppName {
    param (
        [string]$AppJsonFile
    )

    if (-Not (Test-Path $AppJsonFile)) {
        Write-EnhancedLog -Message "App JSON file not found: $AppJsonFile" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        throw "App JSON file missing"
    }

    $appConfig = Get-Content -Path $AppJsonFile | ConvertFrom-Json
    $baseAppName = $appConfig.AppName
    $timestamp = (Get-Date).ToString("yyyyMMddHHmmss")
    $uniqueAppName = "$baseAppName-$timestamp"

    Write-EnhancedLog -Message "Generated unique app name: $uniqueAppName" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)
    return $uniqueAppName
}
