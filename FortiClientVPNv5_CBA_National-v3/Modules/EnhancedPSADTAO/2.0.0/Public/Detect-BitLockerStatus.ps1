function Detect-BitLockerStatus {
    [CmdletBinding()]
    param (
        [string[]]$DriveLetters = @("C:")
    )

    begin {
        Write-EnhancedLog -Message 'Starting Detect-BitLockerStatus function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        foreach ($drive in $DriveLetters) {
            try {
                $bitLockerStatus = Get-BitLockerVolume -MountPoint $drive

                if ($bitLockerStatus) {
                    $protectionStatus = $bitLockerStatus.ProtectionStatus
                    Write-EnhancedLog -Message "BitLocker status for drive $drive $protectionStatus" -Level 'INFO'
                    Write-Output "BitLocker status for drive $drive $protectionStatus"
                } else {
                    Write-EnhancedLog -Message "BitLocker status not found for drive $drive" -Level 'WARNING'
                    Write-Output "BitLocker status not found for drive $drive"
                }
            } catch {
                Handle-Error -ErrorRecord $_
            }
        }
    }

    end {
        Write-EnhancedLog -Message 'Detect-BitLockerStatus function completed' -Level 'INFO'
    }
}

# # Example usage of Detect-BitLockerStatus function with splatting
# $params = @{
#     DriveLetters = @("C:", "D:")
# }

# # Call the Detect-BitLockerStatus function using splatting
# Detect-BitLockerStatus @params
