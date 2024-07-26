function Disable-BitLocker {
    [CmdletBinding()]
    param (
        [string[]]$DriveLetters = @("C:")
    )

    begin {
        Write-EnhancedLog -Message 'Starting Disable-BitLocker function' -Level 'INFO'
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
                    Write-EnhancedLog -Message "Disabling BitLocker on drive $drive" -Level 'INFO'
                    Disable-BitLocker -MountPoint $drive -RebootCount 0 -Wait

                    Write-EnhancedLog -Message "BitLocker disabled on drive $drive" -Level 'INFO'
                    Write-Output "BitLocker disabled on drive $drive"
                } catch {
                    Handle-Error -ErrorRecord $_
                }
            } else {
                Write-EnhancedLog -Message "BitLocker is not enabled on drive $drive" -Level 'INFO'
                Write-Output "BitLocker is not enabled on drive $drive"
            }
        }
    }

    end {
        Write-EnhancedLog -Message 'Disable-BitLocker function completed' -Level 'INFO'
    }
}

# # Example usage of Disable-BitLocker function with splatting
# $params = @{
#     DriveLetters = @("C:", "D:")
# }

# # Call the Disable-BitLocker function using splatting
# Disable-BitLocker @params
