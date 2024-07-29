function Send-TokenRequest {
    param (
        [Parameter(Mandatory = $true)]
        [string]$tokenEndpoint,
        [Parameter(Mandatory = $true)]
        [string]$clientId,
        [Parameter(Mandatory = $true)]
        [string]$clientAssertion
    )

    $body = @{
        client_id = $clientId
        scope = "https://graph.microsoft.com/.default"
        client_assertion = $clientAssertion
        client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
        grant_type = "client_credentials"
    }

    try {
        Write-EnhancedLog -Message "Sending request to token endpoint: $tokenEndpoint" -Level "INFO"
        $response = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -ContentType "application/x-www-form-urlencoded" -Body $body
        Write-EnhancedLog -Message "Successfully obtained access token." -Level "INFO"
        return $response.access_token
    }
    catch {
        Write-EnhancedLog -Message "Error obtaining access token: $_"
        throw $_
    }
}