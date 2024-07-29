function Load-Certificate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$CertPath,

        [Parameter(Mandatory = $true)]
        [string]$CertPassword
    )

    try {
        Write-EnhancedLog -Message "Attempting to load certificate from path: $CertPath" -Level "INFO"

        # Validate certificate path before loading
        $certExistsBefore = Validate-Certificate -CertPath $CertPath
        if (-not $certExistsBefore) {
            throw "Certificate path does not exist: $CertPath"
        }

        # Check the OS and convert the certificate path if running on Linux
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            if ($PSVersionTable.Platform -eq 'Unix') {
                $CertPath = Convert-WindowsPathToLinuxPath -WindowsPath $CertPath
            }
        } else {
            $os = [System.Environment]::OSVersion.Platform
            if ($os -eq [System.PlatformID]::Unix) {
                $CertPath = Convert-WindowsPathToLinuxPath -WindowsPath $CertPath
            }
        }

        # Load the certificate directly from the file
        $cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($CertPath, $CertPassword)
        
        Write-EnhancedLog -Message "Successfully loaded certificate from path: $CertPath" -Level "INFO"

        # Validate certificate path after loading
        $certExistsAfter = Validate-Certificate -CertPath $CertPath
        if ($certExistsAfter) {
            Write-EnhancedLog -Message "Certificate path still exists after loading: $CertPath" -Level "INFO"
        } else {
            Write-EnhancedLog -Message "Certificate path does not exist after loading: $CertPath" -Level "WARNING"
        }

        return $cert
    }
    catch {
        Write-EnhancedLog -Message "Error loading certificate from path: $CertPath. Error: $_" -Level "ERROR"
        throw $_
    }
}
