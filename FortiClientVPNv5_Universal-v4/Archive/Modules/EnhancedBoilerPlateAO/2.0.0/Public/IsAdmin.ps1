function IsAdmin {
    <#
    .SYNOPSIS
    Checks if the current user is an administrator.
    #>
    [CmdletBinding()]
    param ()

    Begin {
        Write-EnhancedLog -Message "Starting Is-Admin function" -Level "INFO"
    }

    Process {
        try {
            Write-EnhancedLog -Message "Checking if the current user is an administrator" -Level "INFO"
            $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
            $principal = [Security.Principal.WindowsPrincipal] $identity
            $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
            
            if ($isAdmin) {
                Write-EnhancedLog -Message "Current user is an administrator" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
            } else {
                Write-EnhancedLog -Message "Current user is not an administrator" -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
            }
            
            return $isAdmin
        } catch {
            Write-EnhancedLog -Message "An error occurred while checking administrator status: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            return $false
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Is-Admin function" -Level "INFO"
    }
}
