function Set-ODKFMRegistrySettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TenantID,
        [Parameter(Mandatory = $true)]
        [string]$RegKeyPath,
        [Parameter(Mandatory = $true)]
        [array]$RegistrySettings
    )

    Begin {
        Write-EnhancedLog -Message "Starting Set-ODKFMRegistrySettings function" -Level "INFO"
        Log-Params -Params @{
            TenantID         = $TenantID
            RegKeyPath       = $RegKeyPath
            RegistrySettings = $RegistrySettings
        }
    }

    Process {
        try {
            foreach ($setting in $RegistrySettings) {
                # Define the parameters to be splatted
                $SplatParams = @{
                    RegKeyPath   = $RegKeyPath
                    RegValueName = $setting.RegValueName
                    RegValType   = $setting.RegValType
                    RegValData   = $setting.RegValData
                }

                # Call the function with splatted parameters
                Set-RegistryValue @SplatParams

            }
        }
        catch {
            Write-EnhancedLog -Message "An error occurred while setting OneDrive KFM registry values: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Set-ODKFMRegistrySettings function" -Level "INFO"
    }
}


# $TenantID = "YourTenantID"

# $RegistrySettings = @(
#     @{
#         RegValueName = "AllowTenantList"
#         RegValType   = "STRING"
#         RegValData   = $TenantID
#     },
#     @{
#         RegValueName = "SilentAccountConfig"
#         RegValType   = "DWORD"
#         RegValData   = "1"
#     },
#     @{
#         RegValueName = "KFMOptInWithWizard"
#         RegValType   = "STRING"
#         RegValData   = $TenantID
#     },
#     @{
#         RegValueName = "KFMSilentOptIn"
#         RegValType   = "STRING"
#         RegValData   = $TenantID
#     },
#     @{
#         RegValueName = "KFMSilentOptInDesktop"
#         RegValType   = "DWORD"
#         RegValData   = "1"
#     },
#     @{
#         RegValueName = "KFMSilentOptInDocuments"
#         RegValType   = "DWORD"
#         RegValData   = "1"
#     },
#     @{
#         RegValueName = "KFMSilentOptInPictures"
#         RegValType   = "DWORD"
#         RegValData   = "1"
#     }
# )

# $SetODKFMRegistrySettingsParams = @{
#     TenantID           = $TenantID
#     RegKeyPath         = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
#     RegistrySettings   = $RegistrySettings
# }

# Set-ODKFMRegistrySettings @SetODKFMRegistrySettingsParams


#optionally you can create an event source here using Create-EventLogSource.ps1