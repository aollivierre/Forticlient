function ConfigureVMBoot {
    <#
    .SYNOPSIS
    Configures the boot order of the specified VM to boot from the specified differencing disk.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $true)]
        [string]$DifferencingDiskPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Configure-VMBoot function" -Level "INFO"
        Log-Params -Params @{ VMName = $VMName; DifferencingDiskPath = $DifferencingDiskPath }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Retrieving hard disk drive for VM: $VMName with path: $DifferencingDiskPath" -Level "INFO"
            $VHD = Get-VMHardDiskDrive -VMName $VMName | Where-Object { $_.Path -eq $DifferencingDiskPath }

            if ($null -eq $VHD) {
                Write-EnhancedLog -Message "No hard disk drive found for VM: $VMName with the specified path: $DifferencingDiskPath" -Level "ERROR"
                throw "Hard disk drive not found."
            }

            Write-EnhancedLog -Message "Setting VM firmware for VM: $VMName to boot from the specified disk" -Level "INFO"
            Set-VMFirmware -VMName $VMName -FirstBootDevice $VHD

            Write-EnhancedLog -Message "VM boot configured for $VMName" -Level "INFO"
        } catch {
            Write-EnhancedLog -Message "An error occurred while configuring VM boot for $VMName $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Configure-VMBoot function" -Level "INFO"
    }
}
