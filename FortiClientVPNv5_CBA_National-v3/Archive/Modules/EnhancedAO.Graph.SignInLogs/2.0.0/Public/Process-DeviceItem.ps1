function Process-DeviceItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Item,
        [Parameter(Mandatory = $true)]
        $Context,
        [Parameter(Mandatory = $true)]
        $Headers
    )

    Begin {
        Write-EnhancedLog -Message "Starting Process-DeviceItem function" -Level "INFO"
        Log-Params -Params @{ Item = $Item; Context = $Context }
    }

    Process {
        $deviceId = $Item.deviceDetail.deviceId
        $userId = $Item.userId

        try {
            # Log the device and user information
            Write-EnhancedLog -Message "Processing device item for user: $($Item.userDisplayName) with unique ID: $($deviceId -or $userId)" -Level "INFO"

            # Handle external Azure AD tenant case
            if ([string]::Equals($deviceId, "{PII Removed}", [System.StringComparison]::OrdinalIgnoreCase)) {
                if ($Context.UniqueDeviceIds.Add($userId)) {
                    Write-EnhancedLog -Message "External Azure AD tenant detected for user: $($Item.userDisplayName)" -Level "INFO"
                    Add-Result -Context $Context -Item $Item -DeviceId "N/A" -DeviceState "External" -HasPremiumLicense $false -OSVersion $null
                }
                return
            }

            # Handle BYOD case
            if ([string]::IsNullOrWhiteSpace($deviceId)) {
                if ($Context.UniqueDeviceIds.Add($userId)) {
                    # Fetch user licenses
                    $userLicenses = Fetch-UserLicense -UserId $userId -Username $Item.userDisplayName -Headers $Headers
                    $hasPremiumLicense = $false

                    if ($null -ne $userLicenses -and $userLicenses.Count -gt 0) {
                        $hasPremiumLicense = $userLicenses.Contains("cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46")
                        Write-EnhancedLog -Message "User $($Item.userDisplayName) has the following licenses: $($userLicenses -join ', ')" -Level "INFO"
                    } else {
                        Write-EnhancedLog -Message "User $($Item.userDisplayName) has no licenses." -Level "INFO"
                    }

                    Add-Result -Context $Context -Item $Item -DeviceId "N/A" -DeviceState "BYOD" -HasPremiumLicense $hasPremiumLicense -OSVersion $null
                }
                return
            }

            # Handle managed device case
            if ($Context.UniqueDeviceIds.Add($deviceId)) {
                # Call the method to check device state
                $deviceState = Check-DeviceStateInIntune -entraDeviceId $deviceId -username $Item.userDisplayName -Headers $Headers

                # Fetch user licenses
                $userLicenses = Fetch-UserLicense -UserId $userId -Username $Item.userDisplayName -Headers $Headers
                $hasPremiumLicense = $false

                if ($null -ne $userLicenses -and $userLicenses.Count -gt 0) {
                    $hasPremiumLicense = $userLicenses.Contains("cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46")
                    Write-EnhancedLog -Message "User $($Item.userDisplayName) has the following licenses: $($userLicenses -join ', ')" -Level "INFO"
                } else {
                    Write-EnhancedLog -Message "User $($Item.userDisplayName) has no licenses." -Level "INFO"
                }

                # Fetch OS version
                $osVersion = Fetch-OSVersion -DeviceId $deviceId -Headers $Headers

                Add-Result -Context $Context -Item $Item -DeviceId $deviceId -DeviceState $deviceState -HasPremiumLicense $hasPremiumLicense -OSVersion $osVersion
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while processing the device item for user: $($Item.userDisplayName) - $_" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Process-DeviceItem function" -Level "INFO"
    }
}
