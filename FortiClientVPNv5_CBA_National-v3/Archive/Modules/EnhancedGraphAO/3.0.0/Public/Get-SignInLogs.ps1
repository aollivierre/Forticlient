function Get-SignInLogs {
    param (
        [string]$url,
        [hashtable]$headers
    )

    $allLogs = @()

    while ($url) {
        try {
            Write-EnhancedLog -Message "Requesting URL: $url" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)
            # Make the API request
            $response = Invoke-WebRequest -Uri $url -Headers $headers -Method Get
            $data = ($response.Content | ConvertFrom-Json)

            # Collect the logs
            $allLogs += $data.value

            # Check for pagination
            $url = $data.'@odata.nextLink'
        } catch {
            Write-EnhancedLog -Message "Error: $($_.Exception.Message)" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
            break
        }
    }

    return $allLogs
}
