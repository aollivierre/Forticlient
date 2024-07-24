function Validate-Certificate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$CertPath
    )

    try {
        if (Test-Path -Path $CertPath) {
            Write-EnhancedLog -Message "Certificate path exists: $CertPath" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
            return $true
        } else {
            Write-EnhancedLog -Message "Certificate path does not exist: $CertPath" -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
            return $false
        }
    }
    catch {
        Write-EnhancedLog -Message "Error validating certificate path: $CertPath. Error: $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        throw $_
    }
}
