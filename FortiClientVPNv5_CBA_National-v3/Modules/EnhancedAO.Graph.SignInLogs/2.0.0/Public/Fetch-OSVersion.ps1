function Fetch-OSVersion {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DeviceId,
        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    Begin {
        Write-EnhancedLog -Message "Starting Fetch-OSVersion function for Device ID: $DeviceId" -Level "INFO"
        Log-Params -Params @{ DeviceId = $DeviceId }
    }

    Process {
        $uri = "https://graph.microsoft.com/v1.0/devices?$filter=deviceId eq '$DeviceId'"
        $httpClient = Initialize-HttpClient -Headers $Headers

        try {
            Write-EnhancedLog -Message "Fetching OS version from URL: $uri" -Level "INFO"

            $response = $httpClient.GetStringAsync($uri).Result
            if (-not [string]::IsNullOrEmpty($response)) {
                $responseJson = [System.Text.Json.JsonDocument]::Parse($response)
                $deviceDetails = $responseJson.RootElement.GetProperty("value").EnumerateArray() | Where-Object { $_.GetProperty("deviceId").GetString() -eq $DeviceId }

                if ($deviceDetails) {
                    $osVersion = $deviceDetails.GetProperty("operatingSystemVersion").GetString()
                    Write-EnhancedLog -Message "OS Version for Device ID $DeviceId $osVersion" -Level "INFO"
                    $responseJson.Dispose()
                    return $osVersion
                } else {
                    Write-EnhancedLog -Message "No matching device found for Device ID $DeviceId" -Level "WARNING" -ForegroundColor Yellow
                    return $null
                }
            } else {
                Write-EnhancedLog -Message "Received empty response from OS version API for Device ID: $DeviceId." -Level "WARNING" -ForegroundColor Yellow
                return $null
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while fetching OS version: $($_.Exception.Message)" -Level "ERROR" -ForegroundColor Red
            Handle-Error -ErrorRecord $_
            return $null
        } finally {
            $httpClient.Dispose()
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Fetch-OSVersion function for Device ID: $DeviceId" -Level "INFO"
    }
}
