function Initialize-HttpClient {
    param (
        [hashtable]$Headers
    )

    $httpClient = [System.Net.Http.HttpClient]::new()
    $httpClient.DefaultRequestHeaders.Add("Authorization", $Headers["Authorization"])
    return $httpClient
}


function Get-UserLicenses {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserId,
        [Parameter(Mandatory = $true)]
        [string]$Username,
        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    Begin {
        Write-EnhancedLog -Message "Starting Get-UserLicenses function" -Level "INFO"
        Log-Params -Params @{ UserId = $UserId; Username = $Username }
    }

    Process {
        $licenses = [System.Collections.Generic.List[string]]::new()
        $uri = "https://graph.microsoft.com/v1.0/users/$UserId/licenseDetails"
        $httpClient = Initialize-HttpClient -Headers $Headers

        try {
            Write-EnhancedLog -Message "Fetching licenses for user ID: $UserId with username: $Username" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)

            $response = $httpClient.GetStringAsync($uri).Result
            if (-not [string]::IsNullOrEmpty($response)) {
                $responseJson = [System.Text.Json.JsonDocument]::Parse($response)
                $valueProperty = $responseJson.RootElement.GetProperty("value")
                foreach ($license in $valueProperty.EnumerateArray()) {
                    $skuId = $license.GetProperty("skuId").GetString()
                    $licenses.Add($skuId)
                    Write-EnhancedLog -Message "Found license for user: $Username with SKU ID: $skuId" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
                }
                $responseJson.Dispose()
            } else {
                Write-EnhancedLog -Message "Received empty response from license API." -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while fetching licenses: $($_.Exception.Message)" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
            Handle-Error -ErrorRecord $_
            throw
        } finally {
            $httpClient.Dispose()
        }

        return $licenses
    }

    End {
        Write-EnhancedLog -Message "Exiting Get-UserLicenses function" -Level "INFO"
    }
}





# # Example usage
# $userId = "your_user_id"
# $username = "your_username"
# $headers = @{ "Authorization" = "Bearer your_token" }

# $licenses = Get-UserLicenses -UserId $userId -Username $username -Headers $headers
# Write-Output "Licenses: $($licenses -join ', ')"



