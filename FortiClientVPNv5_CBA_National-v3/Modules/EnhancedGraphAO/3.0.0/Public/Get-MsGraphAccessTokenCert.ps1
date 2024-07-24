function Get-MsGraphAccessTokenCert {
    param (
        [Parameter(Mandatory = $true)]
        [string]$tenantId,
        [Parameter(Mandatory = $true)]
        [string]$clientId,
        [Parameter(Mandatory = $true)]
        [string]$certPath,
        [Parameter(Mandatory = $true)]
        [string]$certPassword
    )

    $tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

    # Load the certificate
    $cert = Load-Certificate -certPath $certPath -certPassword $certPassword

    # Create JWT header
    $jwtHeader = @{
        alg = "RS256"
        typ = "JWT"
        x5t = [Convert]::ToBase64String($cert.GetCertHash())
    }

    $now = [System.DateTime]::UtcNow
    Write-EnhancedLog -Message "Current UTC Time: $now"

    # Get nbf and exp times
    $nbfTime = Get-UnixTime -offsetMinutes -5  # nbf is 5 minutes ago
    $expTime = Get-UnixTime -offsetMinutes 55  # exp is 55 minutes from now

    Write-EnhancedLog -Message "nbf (not before) time: $nbfTime"
    Write-EnhancedLog -Message "exp (expiration) time: $expTime"

    # Create JWT payload
    $jwtPayload = @{
        aud = $tokenEndpoint
        exp = $expTime
        iss = $clientId
        jti = [guid]::NewGuid().ToString()
        nbf = $nbfTime
        sub = $clientId
    }

    Write-EnhancedLog -Message "JWT Payload: $(ConvertTo-Json $jwtPayload -Compress)"

    # Generate JWT assertion
    $clientAssertion = Generate-JWTAssertion -jwtHeader $jwtHeader -jwtPayload $jwtPayload -cert $cert

    # Send token request
    return Send-TokenRequest -tokenEndpoint $tokenEndpoint -clientId $clientId -clientAssertion $clientAssertion
}


# # Example usage of Get-MsGraphAccessTokenCert
# $tenantId = "b5dae566-ad8f-44e1-9929-5669f1dbb343"
# $clientId = "8230c33e-ff30-419c-a1fc-4caf98f069c9"
# $certPath = "C:\Code\appgallery\Intune-Win32-Deployer\apps-winget-repo\PR4B_ExportVPNtoSPO-v1\PR4B-ExportVPNtoSPO-v2\graphcert.pfx"
# $certPassword = "somepassword"
# $accessToken = Get-MsGraphAccessTokenCert -tenantId $tenantId -clientId $clientId -certPath $certPath -certPassword $certPassword
# Write-Host "Access Token: $accessToken"
