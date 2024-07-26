function Set-Autologin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TempUser,

        [Parameter(Mandatory = $true)]
        [string]$TempUserPassword,

        [Parameter(Mandatory = $true)]
        [string]$RegPath,

        [Parameter(Mandatory = $true)]
        [string]$AutoAdminLogonName,

        [Parameter(Mandatory = $true)]
        [string]$AutoAdminLogonValue,

        [Parameter(Mandatory = $true)]
        [string]$DefaultUsernameName,

        [Parameter(Mandatory = $true)]
        [string]$DefaultPasswordName
    )

    Begin {
        Write-EnhancedLog -Message "Starting Set-Autologin function" -Level "INFO"
        Log-Params -Params @{
            TempUser           = $TempUser
            TempUserPassword   = $TempUserPassword
            RegPath            = $RegPath
            AutoAdminLogonName = $AutoAdminLogonName
            AutoAdminLogonValue = $AutoAdminLogonValue
            DefaultUsernameName = $DefaultUsernameName
            DefaultPasswordName = $DefaultPasswordName
        }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Setting user account to Auto Login" -Level "INFO"
            Set-ItemProperty -Path $RegPath -Name $AutoAdminLogonName -Value $AutoAdminLogonValue -Type String -Verbose
            Set-ItemProperty -Path $RegPath -Name $DefaultUsernameName -Value $TempUser -Type String -Verbose
            Set-ItemProperty -Path $RegPath -Name $DefaultPasswordName -Value $TempUserPassword -Type String -Verbose
        } catch {
            Write-EnhancedLog -Message "An error occurred while setting autologin: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Set-Autologin function" -Level "INFO"
    }
}

# # Example usage with splatting
# $SetAutologinParams = @{
#     TempUser            = 'YourTempUser'
#     TempUserPassword    = 'YourTempUserPassword'
#     RegPath             = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
#     AutoAdminLogonName  = 'AutoAdminLogon'
#     AutoAdminLogonValue = '1'
#     DefaultUsernameName = 'DefaultUsername'
#     DefaultPasswordName = 'DefaultPassword'
# }

# Set-Autologin @SetAutologinParams
