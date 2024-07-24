function Get-MsGraphAccessToken {
    param (
        [string]$tenantId,
        [string]$clientId,
        [string]$clientSecret
    )

    $tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $body = @{
        client_id     = $clientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }

    $httpClient = New-Object System.Net.Http.HttpClient
    $bodyString = ($body.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'

    try {
        $content = New-Object System.Net.Http.StringContent($bodyString, [System.Text.Encoding]::UTF8, "application/x-www-form-urlencoded")
        $response = $httpClient.PostAsync($tokenEndpoint, $content).Result

        if (-not $response.IsSuccessStatusCode) {
            Write-EnhancedLog -Message "HTTP request failed with status code: $($response.StatusCode)" -Level "ERROR"
            return $null
        }

        $responseContent = $response.Content.ReadAsStringAsync().Result
        $accessToken = (ConvertFrom-Json $responseContent).access_token

        if ($accessToken) {
            Write-EnhancedLog -Message "Access token retrieved successfully" -Level "INFO"
            return $accessToken
        }
        else {
            Write-EnhancedLog -Message "Failed to retrieve access token, response was successful but no token was found." -Level "ERROR"
            return $null
        }
    }
    catch {
        Write-EnhancedLog -Message "Failed to execute HTTP request or process results: $_" -Level "ERROR"
        return $null
    }
}
