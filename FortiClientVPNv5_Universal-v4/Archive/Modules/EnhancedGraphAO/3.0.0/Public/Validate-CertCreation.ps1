function Validate-CertCreation {
    param (
        [string]$Thumbprint,
        [string[]]$StoreLocations = @("Cert:\LocalMachine", "Cert:\CurrentUser")
    )

    foreach ($storeLocation in $StoreLocations) {
        $cert = Get-ChildItem -Path "$storeLocation\My" | Where-Object { $_.Thumbprint -eq $Thumbprint }
        if ($null -ne $cert) {
            Write-EnhancedLog -Message "Certificate validated successfully in $storeLocation" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)
            return $cert
        }
    }

    Write-EnhancedLog -Message "Certificate validation failed" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
    throw "Certificate not found"
    Handle-Error -ErrorRecord $_
}