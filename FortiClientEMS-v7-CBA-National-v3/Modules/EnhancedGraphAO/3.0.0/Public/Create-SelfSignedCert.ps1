# function Create-SelfSignedCert {
#     param (
#         [string]$CertName,
#         [string]$CertStoreLocation = "Cert:\CurrentUser\My",
#         [string]$TenantName,
#         [string]$AppId
#     )

#     $cert = New-SelfSignedCertificate -CertStoreLocation $CertStoreLocation `
#         -Subject "CN=$CertName, O=$TenantName, OU=$AppId" `
#         -KeyLength 2048 `
#         -NotAfter (Get-Date).AddDays(30)

#     if ($null -eq $cert) {
#         Write-EnhancedLog -Message "Failed to create certificate" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
#         throw "Certificate creation failed"
#     }
#     Write-EnhancedLog -Message "Certificate created successfully" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)
#     return $cert
# }







# function Create-SelfSignedCert {
#     param (
#         [string]$CertName,
#         [string]$CertStoreLocation = "Cert:\CurrentUser\My",
#         [string]$TenantName,
#         [string]$AppId,
#         # [string]$OutputPath = "C:\Certificates",
#         [string]$OutputPath,
#         # [string]$PfxPassword = "YourPfxPassword"
#         [string]$PfxPassword
#     )

#     try {
#         # Create output directory if it doesn't exist
#         if (-not (Test-Path -Path $OutputPath)) {
#             New-Item -ItemType Directory -Path $OutputPath
#         }

#         # Define certificate subject details
#         $subject = "CN=$CertName, O=$TenantName, OU=$AppId, L=City, S=State, C=US"

#         # Generate the self-signed certificate
#         $cert = New-SelfSignedCertificate -CertStoreLocation $CertStoreLocation `
#             -Subject $subject `
#             -KeyLength 2048 `
#             -KeyExportPolicy Exportable `
#             -NotAfter (Get-Date).AddDays(30) `
#             -KeyUsage DigitalSignature, KeyEncipherment `
#             -FriendlyName "$CertName for $TenantName"

#         if ($null -eq $cert) {
#             Write-EnhancedLog -Message "Failed to create certificate" -Level "ERROR"
#             throw "Certificate creation failed"
#         }

#         Write-EnhancedLog -Message "Certificate created successfully" -Level "INFO"

#         # Convert password to secure string
#         $securePfxPassword = ConvertTo-SecureString -String $PfxPassword -Force -AsPlainText

#         # Export the certificate to a PFX file
#         $pfxFilePath = Join-Path -Path $OutputPath -ChildPath "$CertName-$TenantName-$AppId.pfx"
#         Export-PfxCertificate -Cert $cert -FilePath $pfxFilePath -Password $securePfxPassword

#         Write-EnhancedLog -Message "PFX file created successfully at $pfxFilePath" -Level "INFO"

#         # Export the private key
#         $privateKeyFilePath = Join-Path -Path $OutputPath -ChildPath "$CertName-$TenantName-$AppId.key"
#         $privateKey = $cert.PrivateKey
#         $privateKeyBytes = [System.Convert]::ToBase64String($privateKey.ExportCspBlob($true))
#         Set-Content -Path $privateKeyFilePath -Value $privateKeyBytes

#         Write-EnhancedLog -Message "Private key file created successfully at $privateKeyFilePath" -Level "INFO"

#         return $cert

#     } catch {
#         Write-EnhancedLog -Message "An error occurred while creating the self-signed certificate" -Level "ERROR"
#         Handle-Error -ErrorRecord $_ 
#         throw $_
#     }
# }

# Example usage
# $cert = Create-SelfSignedCert -CertName "GraphCert" -TenantName "YourTenantName" -AppId "YourAppId" -OutputPath $OutputPath















# function Create-SelfSignedCert {
#     param (
#         [string]$CertName,
#         [string]$CertStoreLocation = "Cert:\CurrentUser\My",
#         [string]$TenantName,
#         [string]$AppId,
#         [string]$OutputPath,
#         [string]$PfxPassword
#     )

#     try {
#         # Create output directory if it doesn't exist
#         if (-not (Test-Path -Path $OutputPath)) {
#             New-Item -ItemType Directory -Path $OutputPath -Force
#         }

#         # Get the logged-in user for the Graph API session
#         Write-EnhancedLog -Message "Fetching current user information from Microsoft Graph API." -Level "INFO"
#         $currentUserResponse = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/me" -Method GET
#         Write-EnhancedLog -Message "Response from Microsoft Graph API: $($currentUserResponse | ConvertTo-Json -Compress)" -Level "DEBUG"

#         $currentUser = $currentUserResponse

#         # $DBG

#         # Define certificate subject details
#         $subject = "CN=$CertName-$AppId, O=$TenantName, OU=$AppId, L=City, S=State, C=US"

#         # Generate the self-signed certificate
#         $certParams = @{
#             CertStoreLocation = $CertStoreLocation
#             Subject           = $subject
#             Issuer            = "CN=$($currentUser.DisplayName)-$($currentUser.userPrincipalName)"
#             KeyLength         = 2048
#             KeyExportPolicy   = "Exportable"
#             NotAfter          = (Get-Date).AddDays(30)
#             KeyUsage          = "DigitalSignature, KeyEncipherment"
#             FriendlyName      = "$CertName-$AppId for $TenantName"
#         }

#         # Generate the self-signed certificate
#         $cert = New-SelfSignedCertificate @certParams

#         $DBG

#         if ($null -eq $cert) {
#             Write-EnhancedLog -Message "Failed to create certificate" -Level "ERROR"
#             throw "Certificate creation failed"
#         }

#         Write-EnhancedLog -Message "Certificate created successfully" -Level "INFO"

#         # Convert password to secure string
#         $securePfxPassword = ConvertTo-SecureString -String $PfxPassword -Force -AsPlainText

#         # Export the certificate to a PFX file
#         # $pfxFilePath = Join-Path -Path "$OutputPath" -ChildPath "$CertName-$TenantName-$AppId.pfx"
#         $pfxFilePath = $null
#         # $pfxFilePath = Join-Path -Path "$OutputPath" -ChildPath "$CertName-$TenantName.pfx"
#         $pfxFilePath = Join-Path -Path "$OutputPath" -ChildPath "$CertName.pfx"
#         # $pfxFilePath = Join-Path -Path "$OutputPath" -ChildPath "1.pfx"

#         # $pfxFilePath = "C:\Code\GraphAppwithCert\Graph\Information and Communications Technology Council_b5dae566-ad8f-44e1-9929-5669f1dbb343\c.pfx"

#         # $DBG

#         Export-PfxCertificate -Cert $cert -FilePath "$pfxFilePath" -Password $securePfxPassword

#         Write-EnhancedLog -Message "Certificate $cert exported successfully to pfx file located in $pfxFilePath " -Level "INFO"

#         $DBG

#         Write-EnhancedLog -Message "PFX file created successfully at $pfxFilePath" -Level "INFO"

#         # Export the private key
#         # $privateKeyFilePath = Join-Path -Path "$OutputPath" -ChildPath "$CertName-$TenantName-$AppId.key"
#         $privateKeyFilePath = Join-Path -Path "$OutputPath" -ChildPath "$CertName-$TenantName.key"
#         $privateKey = $cert.PrivateKey

#         $rsaParameters = $privateKey.ExportParameters($true)
#         $privateKeyPem = Convert-RsaParametersToPem -rsaParameters $rsaParameters
#         Set-Content -Path $privateKeyFilePath -Value $privateKeyPem

#         Write-EnhancedLog -Message "Private key file created successfully at $privateKeyFilePath" -Level "INFO"

#         return $cert

#     }
#     catch {
#         Write-EnhancedLog -Message "An error occurred while creating the self-signed certificate" -Level "ERROR"
#         Handle-Error -ErrorRecord $_ 
#         throw $_
#     }
# }



# # Example usage
# $certParams = @{
#     CertName   = "GraphCert"
#     TenantName = "YourTenantName"
#     AppId      = "YourAppId"
#     OutputPath = "C:\Certificates"
#     PfxPassword = "YourPfxPassword"
# }
# $cert = Create-SelfSignedCert @certParams










# function Create-SelfSignedCert {
#     param (
#         [string]$CertName,
#         [string]$CertStoreLocation = "Cert:\CurrentUser\My",
#         [string]$TenantName,
#         [string]$AppId,
#         [string]$OutputPath,
#         [string]$PfxPassword
#     )

#     try {
#         # Get the logged-in user for the Graph API session
#         Write-EnhancedLog -Message "Fetching current user information from Microsoft Graph API." -Level "INFO"
#         $currentUserResponse = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/me" -Method GET
#         Write-EnhancedLog -Message "Response from Microsoft Graph API: $($currentUserResponse | ConvertTo-Json -Compress)" -Level "DEBUG"

#         $currentUser = $currentUserResponse

#         # Create output directory if it doesn't exist
#         if (-not (Test-Path -Path $OutputPath)) {
#             New-Item -ItemType Directory -Path $OutputPath
#         }

#         # Define certificate subject details
#         $subject = "CN=$CertName-$AppId, O=$TenantName, OU=$AppId, L=City, S=State, C=US"

#         # Splat the parameters
#         $certParams = @{
#             CertStoreLocation = $CertStoreLocation
#             Subject           = $subject
#             Issuer            = "CN=$($currentUser.displayName)"
#             KeyLength         = 2048
#             KeyExportPolicy   = "Exportable"
#             NotAfter          = (Get-Date).AddDays(30)
#             KeyUsage          = @("DigitalSignature", "KeyEncipherment")
#             FriendlyName      = "$CertName-$AppId for $TenantName"
#         }

#         # Generate the self-signed certificate
#         $cert = New-SelfSignedCertificate @certParams

#         if ($null -eq $cert) {
#             Write-EnhancedLog -Message "Failed to create certificate" -Level "ERROR"
#             throw "Certificate creation failed"
#         }

#         Write-EnhancedLog -Message "Certificate created successfully" -Level "INFO"

#         # Convert password to secure string
#         $securePfxPassword = ConvertTo-SecureString -String $PfxPassword -Force -AsPlainText

#         # Export the certificate to a PFX file
#         $pfxFilePath = Join-Path -Path $OutputPath -ChildPath "$CertName-$TenantName-$AppId.pfx"
#         Export-PfxCertificate -Cert $cert -FilePath $pfxFilePath -Password $securePfxPassword

#         Write-EnhancedLog -Message "PFX file created successfully at $pfxFilePath" -Level "INFO"

#         return $cert

#     } catch {
#         Write-EnhancedLog -Message "An error occurred while creating the self-signed certificate." -Level "ERROR"
#         Handle-Error -ErrorRecord $_ 
#         throw $_
#     }
# }

# Example usage
# $scopes = @("User.Read.All", "Application.ReadWrite.All", "Directory.ReadWrite.All")
# Connect-MgGraph -Scopes $scopes

# $certParams = @{
#     CertName     = "GraphCert"
#     TenantName   = $tenantDetails.DisplayName
#     AppId        = $app.AppId
#     OutputPath   = $certexportDirectory
#     PfxPassword  = $certPassword
# }
# $cert = Create-SelfSignedCert @certParams






function Create-SelfSignedCert {
    param (
        [string]$CertName,
        [string]$CertStoreLocation = "Cert:\CurrentUser\My",
        [string]$TenantName,
        [string]$AppId,
        [string]$OutputPath,
        [string]$PfxPassword
    )

    try {
        # Get the logged-in user for the Graph API session
        Write-EnhancedLog -Message "Fetching current user information from Microsoft Graph API." -Level "INFO"
        $currentUserResponse = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/me" -Method GET
        Write-EnhancedLog -Message "Response from Microsoft Graph API: $($currentUserResponse | ConvertTo-Json -Compress)" -Level "DEBUG"

        $currentUser = $currentUserResponse

        # Create output directory if it doesn't exist
        if (-not (Test-Path -Path $OutputPath)) {
            New-Item -ItemType Directory -Path $OutputPath
        }

         # Define certificate subject details
        $subject = "CN=$CertName-$AppId, O=$TenantName, OU=$AppId, L=City, S=State, C=US"
        $Issuer  = "CN=$($currentUser.DisplayName)-$($currentUser.userPrincipalName)"

        # Splat the parameters
        $certParams = @{
            CertStoreLocation = $CertStoreLocation
            Subject           = $subject
            KeyLength         = 2048
            KeyExportPolicy   = "Exportable"
            NotAfter          = (Get-Date).AddDays(30)
            KeyUsage          = @("DigitalSignature", "KeyEncipherment")
            FriendlyName      = "$CertName-$AppId for $TenantName by $Issuer"
        }

        # Generate the self-signed certificate
        $cert = New-SelfSignedCertificate @certParams

        if ($null -eq $cert) {
            Write-EnhancedLog -Message "Failed to create certificate" -Level "ERROR"
            throw "Certificate creation failed"
        }

        Write-EnhancedLog -Message "Certificate created successfully" -Level "INFO"

        # Convert password to secure string
        $securePfxPassword = ConvertTo-SecureString -String $PfxPassword -Force -AsPlainText

        # Export the certificate to a PFX file
        $pfxFilePath = Join-Path -Path $OutputPath -ChildPath "$CertName-$AppId.pfx"
        Export-PfxCertificate -Cert $cert -FilePath $pfxFilePath -Password $securePfxPassword

        Write-EnhancedLog -Message "PFX file created successfully at $pfxFilePath" -Level "INFO"


        # $DBG

        return $cert

    } catch {
        Write-EnhancedLog -Message "An error occurred while creating the self-signed certificate." -Level "ERROR"
        Handle-Error -ErrorRecord $_ 
        throw $_
    }
}

# # Example usage
# $scopes = @("User.Read.All", "Application.ReadWrite.All", "Directory.ReadWrite.All")
# Connect-MgGraph -Scopes $scopes

# $certParams = @{
#     CertName     = "GraphCert"
#     TenantName   = $tenantDetails.DisplayName
#     AppId        = $app.AppId
#     OutputPath   = $certexportDirectory
#     PfxPassword  = $certPassword
# }
# $cert = Create-SelfSignedCert @certParams






