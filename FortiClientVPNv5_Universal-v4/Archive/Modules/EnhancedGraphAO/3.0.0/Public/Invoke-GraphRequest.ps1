function Invoke-GraphRequest {
    param (
        [string]$Method,
        [string]$Uri,
        [string]$AccessToken,
        [string]$Body = $null
    )

    $httpClient = New-Object System.Net.Http.HttpClient
    $httpClient.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", $AccessToken)

    try {
        if ($Body) {
            $content = New-Object System.Net.Http.StringContent($Body, [System.Text.Encoding]::UTF8, "application/json")
        }

        $response = $null
        switch ($Method) {
            "GET" { $response = $httpClient.GetAsync($Uri).Result }
            "POST" { $response = $httpClient.PostAsync($Uri, $content).Result }
            "PATCH" { $response = $httpClient.PatchAsync($Uri, $content).Result }
            "DELETE" { $response = $httpClient.DeleteAsync($Uri).Result }
        }

        if (-not $response) {
            throw "No response received from the server."
        }

        $responseContent = $response.Content.ReadAsStringAsync().Result
        $responseStatus = $response.IsSuccessStatusCode

        # Define the directory for response JSON files
        $responseDir = Join-Path -Path $PSScriptRoot -ChildPath "responses"
        if (-not (Test-Path -Path $responseDir)) {
            New-Item -ItemType Directory -Path $responseDir
        }

        # Log the full request and response in JSON format
        $logEntry = @{
            RequestUri    = $Uri
            RequestMethod = $Method
            RequestBody   = $Body
            Response      = $responseContent
            IsSuccess     = $responseStatus
            TimeStamp     = Get-Date -Format "yyyyMMddHHmmssfff"
        }

        $logFile = Join-Path -Path $responseDir -ChildPath ("Response_$($logEntry.TimeStamp).json")
        $logEntry | ConvertTo-Json | Set-Content -Path $logFile

        Write-EnhancedLog -Message "Response logged to $logFile" -Level "INFO"

        if ($response.IsSuccessStatusCode) {
            Write-EnhancedLog -Message "Successfully executed $Method request to $Uri." -Level "INFO"
            return $responseContent
        }
        else {
            $errorContent = $responseContent
            Write-EnhancedLog -Message "HTTP request failed with status code: $($response.StatusCode). Error content: $errorContent" -Level "ERROR"
            return $null
        }
    }
    catch {
        Write-EnhancedLog -Message "Failed to execute $Method request to $Uri $_" -Level "ERROR"
        return $null
    }
    finally {
        $httpClient.Dispose()
    }
}
