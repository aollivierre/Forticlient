function Get-NextVMNamePrefix {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Config
    )

    Begin {
        Write-EnhancedLog -Message "Starting Get-NextVMNamePrefix function" -Level "INFO"
    }

    Process {
        try {
            Write-EnhancedLog -Message "Retrieving the most recent VM" -Level "INFO"
            $mostRecentVM = Get-VM | Sort-Object -Property CreationTime -Descending | Select-Object -First 1
            $prefixNumber = 0

            if ($null -ne $mostRecentVM) {
                Write-EnhancedLog -Message "Most recent VM found: $($mostRecentVM.Name)" -Level "INFO"
                if ($mostRecentVM.Name -match '^\d+') {
                    $prefixNumber = [int]$matches[0]
                    Write-EnhancedLog -Message "Extracted prefix number: $prefixNumber" -Level "INFO"
                } else {
                    Write-EnhancedLog -Message "Most recent VM name does not start with a number" -Level "INFO"
                }
            } else {
                Write-EnhancedLog -Message "No existing VMs found" -Level "INFO"
            }

            $nextPrefixNumber = $prefixNumber + 1
            $newVMNamePrefix = $Config.VMNamePrefixFormat -f $nextPrefixNumber
            Write-EnhancedLog -Message "Generated new VM name prefix: $newVMNamePrefix" -Level "INFO"

            return $newVMNamePrefix
        } catch {
            Write-EnhancedLog -Message "An error occurred in Get-NextVMNamePrefix: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Get-NextVMNamePrefix function completed" -Level "INFO"
    }
}
