    # # Define the function
    # function ExportCertificatetoCER {
    #     param (
    #         [Parameter(Mandatory = $true)]
    #         [string]$CertThumbprint,

    #         [Parameter(Mandatory = $true)]
    #         [string]$ExportDirectory
    #     )

    #     try {
    #         # Get the certificate from the current user's personal store
    #         $cert = Get-Item -Path "Cert:\CurrentUser\My\$CertThumbprint"
        
    #         # Ensure the export directory exists
    #         if (-not (Test-Path -Path $ExportDirectory)) {
    #             New-Item -ItemType Directory -Path $ExportDirectory -Force
    #         }

    #         # Dynamically create a file name using the certificate subject name and current timestamp
    #         $timestamp = (Get-Date).ToString("yyyyMMddHHmmss")
    #         $subjectName = $cert.SubjectName.Name -replace "[^a-zA-Z0-9]", "_"
    #         $fileName = "${subjectName}_$timestamp"

    #         # Set the export file path
    #         $certPath = Join-Path -Path $ExportDirectory -ChildPath "$fileName.cer"
        
    #         # Export the certificate to a file (DER encoded binary format with .cer extension)
    #         $cert | Export-Certificate -FilePath $certPath -Type CERT -Force | Out-Null

    #         # Output the export file path
    #         Write-EnhancedLog -Message "Certificate exported to: $certPath"

    #         # Return the export file path
    #         return $certPath
    #     }
    #     catch {
    #         Write-Host "Failed to export certificate: $_" -ForegroundColor Red
    #     }
    # }


    function ExportCertificatetoCER {
        param (
            [Parameter(Mandatory = $true)]
            [string]$CertThumbprint,
    
            [Parameter(Mandatory = $true)]
            [string]$ExportDirectory,

            [Parameter(Mandatory = $true)]
            [string]$Certname
        )
    
        try {
            Write-EnhancedLog -Message "Starting certificate export process for thumbprint: $CertThumbprint" -Level "INFO"
            
            # Get the certificate from the current user's personal store
            $cert = Get-Item -Path "Cert:\CurrentUser\My\$CertThumbprint"
            if (-not $cert) {
                Write-EnhancedLog -Message "Certificate with thumbprint $CertThumbprint not found." -Level "ERROR"
                throw "Certificate with thumbprint $CertThumbprint not found."
            }
            Write-EnhancedLog -Message "Certificate with thumbprint $CertThumbprint found." -Level "INFO"
    
            # Ensure the export directory exists
            if (-not (Test-Path -Path $ExportDirectory)) {
                Write-EnhancedLog -Message "Export directory $ExportDirectory does not exist. Creating directory." -Level "INFO"
                New-Item -ItemType Directory -Path $ExportDirectory -Force
            }
            Write-EnhancedLog -Message "Using export directory: $ExportDirectory" -Level "INFO"
    
            # Dynamically create a file name using the certificate subject name and current timestamp
            $timestamp = (Get-Date).ToString("yyyyMMddHHmmss")
            # $subjectName = $cert.SubjectName.Name -replace "[^a-zA-Z0-9]", "_"
            # $fileName = "${subjectName}_$timestamp"
            $fileName = "${certname}_$timestamp"
    
            # Set the export file path
            $certPath = Join-Path -Path $ExportDirectory -ChildPath "$fileName.cer"
            Write-EnhancedLog -Message "Export file path set to: $certPath" -Level "INFO"
    
            # Export the certificate to a file (DER encoded binary format with .cer extension)

            # $DBG

            Export-Certificate -Cert $cert -FilePath $certPath -Type CERT -Force | Out-Null
            Write-EnhancedLog -Message "Certificate successfully exported to: $certPath" -Level "INFO"
    
            # Return the export file path
            return $certPath
        }
        catch {
            $errorMessage = $_.Exception.Message
            Write-EnhancedLog -Message "Failed to export certificate: $errorMessage" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw $_
        }
    }
    


