# Associate certificate with App Registration
function Add-KeyCredentialToApp {
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppId,

        [Parameter(Mandatory = $true)]
        [string]$CertPath
    )

    # Read the certificate file using the constructor
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertPath)
    $certBytes = $cert.RawData
    $base64Cert = [System.Convert]::ToBase64String($certBytes)

    # Convert certificate dates to DateTime and adjust for time zone
    $startDate = [datetime]::Parse($cert.NotBefore.ToString("o"))
    $endDate = [datetime]::Parse($cert.NotAfter.ToString("o"))

    # Adjust the start and end dates to ensure they are valid and in UTC
    $startDate = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($startDate, [System.TimeZoneInfo]::Local.Id, 'UTC')
    $endDate = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($endDate, [System.TimeZoneInfo]::Local.Id, 'UTC')

    # Adjust end date by subtracting one day to avoid potential end date issues
    $endDate = $endDate.AddDays(-1)

    # Prepare the key credential parameters
    $keyCredentialParams = @{
        CustomKeyIdentifier = [System.Convert]::FromBase64String([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($cert.Thumbprint.Substring(0, 32))))
        DisplayName = "GraphCert"
        EndDateTime = $endDate
        StartDateTime = $startDate
        KeyId = [Guid]::NewGuid().ToString()
        Type = "AsymmetricX509Cert"
        Usage = "Verify"
        Key = $certBytes
    }

    # Create the key credential object
    $keyCredential = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphKeyCredential]::new()
    $keyCredential.CustomKeyIdentifier = $keyCredentialParams.CustomKeyIdentifier
    $keyCredential.DisplayName = $keyCredentialParams.DisplayName
    $keyCredential.EndDateTime = $keyCredentialParams.EndDateTime
    $keyCredential.StartDateTime = $keyCredentialParams.StartDateTime
    $keyCredential.KeyId = $keyCredentialParams.KeyId
    $keyCredential.Type = $keyCredentialParams.Type
    $keyCredential.Usage = $keyCredentialParams.Usage
    $keyCredential.Key = $keyCredentialParams.Key

    # Update the application with the new key credential
    try {
        Update-MgApplication -ApplicationId $AppId -KeyCredentials @($keyCredential)
        Write-Host "Key credential added successfully to the application."
    } catch {
        Write-Host "An error occurred: $_" -ForegroundColor Red
    }
}


