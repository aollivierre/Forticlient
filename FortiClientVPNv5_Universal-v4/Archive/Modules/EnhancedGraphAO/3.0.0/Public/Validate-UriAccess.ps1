function Validate-UriAccess {
    param (
        [string]$uri,
        [hashtable]$headers
    )

    Write-EnhancedLog -Message "Validating access to URI: $uri" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)
    try {
        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Get
        if ($response.StatusCode -eq 200) {
            Write-EnhancedLog -Message "Access to $uri PASS" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
            return $true
        } else {
            Write-EnhancedLog -Message "Access to $uri FAIL" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
            return $false
        }
    } catch {
        Write-EnhancedLog -Message "Access to $uri FAIL - $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        return $false
    }
}
