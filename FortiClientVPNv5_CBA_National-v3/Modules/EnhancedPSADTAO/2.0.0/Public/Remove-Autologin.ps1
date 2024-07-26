function Remove-AutoLogin {
    [CmdletBinding()]

    param ()

    begin {
        Write-EnhancedLog -Message 'Starting Remove-AutoLogin function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            # Check and remove the auto-login registry keys if they exist
            $keysToRemove = @("AutoAdminLogon", "DefaultUserName", "DefaultPassword", "DefaultDomainName")
            foreach ($key in $keysToRemove) {
                $keyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\$key"
                if (Test-Path -Path $keyPath) {
                    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name $key -Force
                    Write-EnhancedLog -Message "Removed auto-login key '$key'." -Level 'INFO'
                } else {
                    Write-EnhancedLog -Message "Auto-login key '$key' does not exist." -Level 'INFO'
                }
            }

            Write-EnhancedLog -Message "Auto-login settings removed." -Level 'INFO'
        } catch {
            Write-EnhancedLog -Message "An error occurred while removing auto-login settings: $_" -Level 'ERROR'
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'Remove-AutoLogin function completed' -Level 'INFO'
    }
}

# Example usage:
# Remove-AutoLogin
