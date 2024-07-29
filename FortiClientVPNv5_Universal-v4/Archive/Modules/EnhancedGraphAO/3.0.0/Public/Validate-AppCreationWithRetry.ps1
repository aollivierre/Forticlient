function Validate-AppCreationWithRetry {
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppName,
        [Parameter(Mandatory = $true)]
        [string]$JsonPath
    )

    $maxDuration = 120  # Maximum duration in seconds (2 minutes)
    $interval = 2       # Interval in seconds
    $elapsed = 0        # Elapsed time counter

    while ($elapsed -lt $maxDuration) {
        try {
            # Validate the app creation
            Write-EnhancedLog -Message 'second validation'
            Remove-AppListJson -jsonPath $jsonPath
            # Start-Sleep -Seconds 30
            Run-DumpAppListToJSON -JsonPath $JsonPath
            $appExists = Validate-AppCreation -AppName $AppName -JsonPath $JsonPath
            if (-not $appExists) {
                Write-EnhancedLog -Message "App creation validation failed" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
                throw "App creation validation failed"
            }

            # If the app validation passes, exit the loop
            break
        }
        catch {
            Write-EnhancedLog -Message "An error occurred during app creation validation: $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
            Start-Sleep -Seconds $interval
            $elapsed += $interval
        }
    }

    if ($elapsed -ge $maxDuration) {
        Write-EnhancedLog -Message "App creation validation failed after multiple retries" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        throw "App creation validation failed after multiple retries"
    }
}