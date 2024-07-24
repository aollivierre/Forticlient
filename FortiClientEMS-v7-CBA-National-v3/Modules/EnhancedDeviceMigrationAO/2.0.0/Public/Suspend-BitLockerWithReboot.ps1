function Suspend-BitLockerWithReboot {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$MountPoint,

        [Parameter(Mandatory = $true)]
        [int]$RebootCount
    )

    Begin {
        Write-EnhancedLog -Message "Starting Suspend-BitLockerWithReboot function" -Level "INFO"
        Log-Params -Params @{
            MountPoint  = $MountPoint
            RebootCount = $RebootCount
        }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Suspending BitLocker" -Level "INFO"
            Suspend-BitLocker -MountPoint $MountPoint -RebootCount $RebootCount -Verbose
        } catch {
            Write-EnhancedLog -Message "An error occurred while suspending BitLocker: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Suspend-BitLockerWithReboot function" -Level "INFO"
    }
}

# # Example usage with splatting
# $SuspendBitLockerWithRebootParams = @{
#     MountPoint  = "C:"
#     RebootCount = 3
# }

# Suspend-BitLockerWithReboot @SuspendBitLockerWithRebootParams
