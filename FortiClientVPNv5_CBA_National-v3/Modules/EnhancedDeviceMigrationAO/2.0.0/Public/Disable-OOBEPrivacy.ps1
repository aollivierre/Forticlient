function Disable-OOBEPrivacy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OOBERegistryPath,

        [Parameter(Mandatory = $true)]
        [string]$OOBEName,

        [Parameter(Mandatory = $true)]
        [string]$OOBEValue,

        [Parameter(Mandatory = $true)]
        [string]$AnimationRegistryPath,

        [Parameter(Mandatory = $true)]
        [string]$AnimationName,

        [Parameter(Mandatory = $true)]
        [string]$AnimationValue,

        [Parameter(Mandatory = $true)]
        [string]$LockRegistryPath,

        [Parameter(Mandatory = $true)]
        [string]$LockName,

        [Parameter(Mandatory = $true)]
        [string]$LockValue
    )

    Begin {
        Write-EnhancedLog -Message "Starting Disable-OOBEPrivacy function" -Level "INFO"
        Log-Params -Params @{
            OOBERegistryPath      = $OOBERegistryPath
            OOBEName              = $OOBEName
            OOBEValue             = $OOBEValue
            AnimationRegistryPath = $AnimationRegistryPath
            AnimationName         = $AnimationName
            AnimationValue        = $AnimationValue
            LockRegistryPath      = $LockRegistryPath
            LockName              = $LockName
            LockValue             = $LockValue
        }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Disabling privacy experience" -Level "INFO"
            if (-not (Test-Path -Path $OOBERegistryPath)) {
                New-Item -Path $OOBERegistryPath -Force | Out-Null
            }
            New-ItemProperty -Path $OOBERegistryPath -Name $OOBEName -Value $OOBEValue -PropertyType DWORD -Force -Verbose

            Write-EnhancedLog -Message "Disabling first logon animation" -Level "INFO"
            if (-not (Test-Path -Path $AnimationRegistryPath)) {
                New-Item -Path $AnimationRegistryPath -Force | Out-Null
            }
            New-ItemProperty -Path $AnimationRegistryPath -Name $AnimationName -Value $AnimationValue -PropertyType DWORD -Force -Verbose

            Write-EnhancedLog -Message "Removing lock screen" -Level "INFO"
            if (-not (Test-Path -Path $LockRegistryPath)) {
                New-Item -Path $LockRegistryPath -Force | Out-Null
            }
            New-ItemProperty -Path $LockRegistryPath -Name $LockName -Value $LockValue -PropertyType DWORD -Force -Verbose
        } catch {
            Write-EnhancedLog -Message "An error occurred while disabling OOBE privacy: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Disable-OOBEPrivacy function" -Level "INFO"
    }
}

# # Example usage with splatting
# $DisableOOBEPrivacyParams = @{
#     OOBERegistryPath      = 'HKLM:\Software\Policies\Microsoft\Windows\OOBE'
#     OOBEName              = 'DisablePrivacyExperience'
#     OOBEValue             = '1'
#     AnimationRegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
#     AnimationName         = 'EnableFirstLogonAnimation'
#     AnimationValue        = '0'
#     LockRegistryPath      = 'HKLM:\Software\Policies\Microsoft\Windows\Personalization'
#     LockName              = 'NoLockScreen'
#     LockValue             = '1'
# }

# Disable-OOBEPrivacy @DisableOOBEPrivacyParams
