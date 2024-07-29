function Validate-VMExists {
    <#
    .SYNOPSIS
    Validates if a VM with the specified name exists.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$VMName
    )

    Begin {
        Write-EnhancedLog -Message "Starting Validate-VMExists function" -Level "INFO"
        Log-Params -Params @{ VMName = $VMName }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Checking existence of VM: $VMName" -Level "INFO"
            $vm = Get-VM -Name $VMName -ErrorAction Stop
            Write-EnhancedLog -Message "VM $VMName exists." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
            return $true
        } catch {
            Write-EnhancedLog -Message "VM $VMName does not exist. $($_.Exception.Message)" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
            Handle-Error -ErrorRecord $_
            return $false
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Validate-VMExists function" -Level "INFO"
    }
}
