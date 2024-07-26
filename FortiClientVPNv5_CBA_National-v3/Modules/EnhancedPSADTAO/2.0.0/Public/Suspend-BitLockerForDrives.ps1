function Suspend-BitLockerForDrives {
    [CmdletBinding()]
    param (
        [string[]]$DriveLetters
    )

    begin {
        Write-EnhancedLog -Message 'Starting Suspend-BitLockerForDrives function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        # Detect BitLocker status for the provided drives
        $bitLockerStatusResults = Detect-BitLockerStatus -DriveLetters $DriveLetters

        foreach ($status in $bitLockerStatusResults) {
            $drive = $status.MountPoint
            $protectionStatus = $status.ProtectionStatus

            if ($protectionStatus -eq "On") {
                try {
                    Write-EnhancedLog -Message "Suspending BitLocker on drive $drive" -Level 'INFO'
                    Suspend-BitLocker -MountPoint $drive -RebootCount 0

                    Write-EnhancedLog -Message "BitLocker suspended on drive $drive" -Level 'INFO'
                } catch {
                    Handle-Error -ErrorRecord $_
                }
            } else {
                Write-EnhancedLog -Message "BitLocker is not enabled on drive $drive" -Level 'INFO'
            }
        }
    }

    end {
        Write-EnhancedLog -Message 'Suspend-BitLockerForDrives function completed' -Level 'INFO'
    }
}

# # Example usage of Suspend-BitLockerForDrives function with splatting
# $params = @{
#     DriveLetters = @("C:", "D:")
# }

# # Call the Suspend-BitLockerForDrives function using splatting
# Suspend-BitLockerForDrives @params
