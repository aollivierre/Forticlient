function Convert-EntraDeviceIdToIntuneDeviceId {
    param (
        [Parameter(Mandatory = $true)]
        [string]$entraDeviceId,
        [hashtable]$headers
    )

    Write-EnhancedLog -Message "Converting Entra Device ID: $entraDeviceId to Intune Device ID" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)

    try {
        # Construct the Graph API URL to retrieve device details
        $graphApiUrl = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?`$filter=azureADDeviceId eq '$entraDeviceId'"
        Write-Output "Constructed Graph API URL: $graphApiUrl"

        # Send the request
        $response = Invoke-WebRequest -Uri $graphApiUrl -Headers $headers -Method Get
        $data = ($response.Content | ConvertFrom-Json).value

        if ($data -and $data.Count -gt 0) {
            $intuneDeviceId = $data[0].id
            Write-EnhancedLog -Message "Converted Entra Device ID: $entraDeviceId to Intune Device ID: $intuneDeviceId" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
            return $intuneDeviceId
        } else {
            Write-EnhancedLog -Message "No Intune Device found for Entra Device ID: $entraDeviceId" -Level "WARN" -ForegroundColor ([ConsoleColor]::Yellow)
            return $null
        }
    } catch {
        Write-EnhancedLog -Message "Error converting Entra Device ID to Intune Device ID: $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        return $null
    }
}

# # Example usage
# $headers = @{ Authorization = "Bearer your-access-token" }
# $entraDeviceId = "73e94a92-fc5a-45b6-bf6c-90ce8a353c44"

# $intuneDeviceId = Convert-EntraDeviceIdToIntuneDeviceId -entraDeviceId $entraDeviceId -Headers $headers
# Write-Output "Intune Device ID: $intuneDeviceId"
