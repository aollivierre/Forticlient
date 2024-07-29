function ConfigureVM {
    <#
    .SYNOPSIS
    Configures the specified VM with the given processor count and memory settings.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $true)]
        [int]$ProcessorCount
    )

    Begin {
        Write-EnhancedLog -Message "Starting Configure-VM function" -Level "INFO"
        Log-Params -Params @{ VMName = $VMName; ProcessorCount = $ProcessorCount }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Configuring VM processor for VM: $VMName with $ProcessorCount processors" -Level "INFO"
            Set-VMProcessor -VMName $VMName -ExposeVirtualizationExtensions $true -Count $ProcessorCount

            Write-EnhancedLog -Message "Configuring memory for VM: $VMName" -Level "INFO"
            Set-VMMemory -VMName $VMName

            Write-EnhancedLog -Message "VM $VMName configured" -Level "INFO"
        } catch {
            Write-EnhancedLog -Message "An error occurred while configuring VM $VMName $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Configure-VM function" -Level "INFO"
    }
}
