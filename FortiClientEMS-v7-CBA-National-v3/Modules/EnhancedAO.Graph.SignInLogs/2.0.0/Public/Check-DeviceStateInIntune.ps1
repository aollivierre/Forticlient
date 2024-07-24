function Initialize-HttpClient {
    param (
        [hashtable]$Headers
    )

    $httpClient = [System.Net.Http.HttpClient]::new()
    $httpClient.DefaultRequestHeaders.Add("Authorization", $Headers["Authorization"])
    return $httpClient
}

function Check-DeviceStateInIntune {
    param (
        [Parameter(Mandatory = $true)]
        [string]$EntraDeviceId,
        [Parameter(Mandatory = $true)]
        [string]$Username,
        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    if ([string]::IsNullOrWhiteSpace($EntraDeviceId)) {
        return "BYOD"
    }

    Write-EnhancedLog -Message "Checking device state in Intune for Entra Device ID: $EntraDeviceId for username: $Username" -ForegroundColor Cyan

    $graphApiUrl = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$filter=azureADDeviceId eq '$EntraDeviceId'"
    Write-EnhancedLog -Message "Constructed Graph API URL: $graphApiUrl"

    $httpClient = Initialize-HttpClient -Headers $Headers

    try {
        $response = $httpClient.GetStringAsync($graphApiUrl).Result

        if (-not [string]::IsNullOrEmpty($response)) {
            $responseJson = [System.Text.Json.JsonDocument]::Parse($response)
            $valueProperty = $responseJson.RootElement.GetProperty("value")

            if ($valueProperty.GetArrayLength() -gt 0) {
                Write-EnhancedLog -Message "Device is present in Intune." -ForegroundColor Green
                return "Present"
            } else {
                Write-EnhancedLog -Message "Device is absent in Intune." -ForegroundColor Yellow
                return "Absent"
            }
        } else {
            Write-EnhancedLog -Message "Received empty response from Intune API." -ForegroundColor Yellow
            return "NoData"
        }
    } catch {
        Handle-Error -ErrorRecord $_
        return "Error"
    } finally {
        if ($null -ne $responseJson) {
            $responseJson.Dispose()
        }
        $httpClient.Dispose()
    }
}

# # Example usage
# $entraDeviceId = "your_device_id"
# $username = "your_username"
# $headers = @{ "Authorization" = "Bearer your_token" }

# $deviceState = Check-DeviceStateInIntune -EntraDeviceId $entraDeviceId -Username $username -Headers $headers
# Write-Output "Device State: $deviceState"
