function CheckAndElevate {
    <#
    .SYNOPSIS
    Elevates the script to run with administrative privileges if not already running as an administrator.

    .DESCRIPTION
    The CheckAndElevate function checks if the current PowerShell session is running with administrative privileges. If it is not, the function attempts to restart the script with elevated privileges using the 'RunAs' verb. This is useful for scripts that require administrative privileges to perform their tasks.

    .EXAMPLE
    CheckAndElevate

    Checks the current session for administrative privileges and elevates if necessary.

    .NOTES
    This function will cause the script to exit and restart if it is not already running with administrative privileges. Ensure that any state or data required after elevation is managed appropriately.
    #>

    [CmdletBinding()]
    param ()

    Begin {
        Write-EnhancedLog -Message "Starting CheckAndElevate function" -Level "INFO"
        try {
            $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
            $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

            Write-EnhancedLog -Message "Checking for administrative privileges..." -Level "INFO"
        } catch {
            Write-EnhancedLog -Message "Error determining administrative status: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw $_
        }
    }

    Process {
        if (-not $isAdmin) {
            try {
                Write-EnhancedLog -Message "The script is not running with administrative privileges. Attempting to elevate..." -Level "WARNING"
                
                $arguments = "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$PSCommandPath`" $args"
                Start-Process PowerShell -Verb RunAs -ArgumentList $arguments

                Write-EnhancedLog -Message "Script re-launched with administrative privileges. Exiting current session." -Level "INFO"
                exit
            } catch {
                Write-EnhancedLog -Message "Failed to elevate privileges: $($_.Exception.Message)" -Level "ERROR"
                Handle-Error -ErrorRecord $_
                throw $_
            }
        } else {
            Write-EnhancedLog -Message "Script is already running with administrative privileges." -Level "INFO"
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting CheckAndElevate function" -Level "INFO"
    }
}

# Example usage
# CheckAndElevate
