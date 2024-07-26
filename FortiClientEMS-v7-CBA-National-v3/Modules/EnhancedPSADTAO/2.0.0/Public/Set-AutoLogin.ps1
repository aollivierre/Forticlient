function Set-AutoLogin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Username = "fcremove",

        [Parameter(Mandatory = $true)]
        [string]$Password = "fcremove",

        [Parameter(Mandatory = $true)]
        [string]$Domain = $env:COMPUTERNAME
    )

    begin {
        Write-EnhancedLog -Message 'Starting Set-AutoLogin function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            # Check and set the auto-login registry keys
            $autoLoginParams = @{
                Path  = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                Name  = "AutoAdminLogon"
                Value = "1"
            }
            if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoAdminLogon") {
                Remove-ItemProperty @autoLoginParams
            }
            Set-ItemProperty @autoLoginParams

            $usernameParams = @{
                Path  = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                Name  = "DefaultUserName"
                Value = $Username
            }
            if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\DefaultUserName") {
                Remove-ItemProperty @usernameParams
            }
            Set-ItemProperty @usernameParams

            $passwordParams = @{
                Path  = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                Name  = "DefaultPassword"
                Value = $Password
            }
            if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\DefaultPassword") {
                Remove-ItemProperty @passwordParams
            }
            Set-ItemProperty @passwordParams

            $domainParams = @{
                Path  = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                Name  = "DefaultDomainName"
                Value = $Domain
            }
            if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\DefaultDomainName") {
                Remove-ItemProperty @domainParams
            }
            Set-ItemProperty @domainParams

            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Name $Username -Force

            Write-EnhancedLog -Message "Auto-login set for user '$Username'." -Level 'INFO'
        } catch {
            Write-EnhancedLog -Message "An error occurred while setting auto-login: $_" -Level 'ERROR'
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'Set-AutoLogin function completed' -Level 'INFO'
    }
}

# # Example usage:
# $autoLoginParams = @{
#     Username = "fcremove"
#     Password = "fcremove"
#     Domain   = $env:COMPUTERNAME
# }
# Set-AutoLogin @autoLoginParams
