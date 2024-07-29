function Validate-VMStarted {
    <#
    .SYNOPSIS
    Validates if the specified VM is started (running).
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$VMName
    )

    Begin {
        Write-EnhancedLog -Message "Starting Validate-VMStarted function" -Level "INFO"
        Log-Params -Params @{ VMName = $VMName }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Checking state of VM: $VMName" -Level "INFO"
            $vm = Get-VM -Name $VMName -ErrorAction Stop

            if ($vm.State -eq 'Running') {
                Write-EnhancedLog -Message "VM $VMName is running." -Level "INFO"
                return $true
            }
            else {
                Write-EnhancedLog -Message "VM $VMName is not running." -Level "WARNING"
                return $false
            }
        }
        catch {
            Write-EnhancedLog -Message "Failed to check the state of VM $VMName. $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            throw $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Validate-VMStarted function" -Level "INFO"
    }
}
