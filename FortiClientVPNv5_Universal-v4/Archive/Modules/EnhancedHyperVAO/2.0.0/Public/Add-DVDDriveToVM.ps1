function Add-DVDDriveToVM {
    <#
    .SYNOPSIS
    Adds a DVD drive with the specified ISO to the VM and validates the addition.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $true)]
        [string]$InstallMediaPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Add-DVDDriveToVM function" -Level "INFO"
        Log-Params -Params @{ VMName = $VMName; InstallMediaPath = $InstallMediaPath }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Validating if the ISO is already added to VM: $VMName" -Level "INFO"
            if (Validate-ISOAdded -VMName $VMName -InstallMediaPath $InstallMediaPath) {
                Write-EnhancedLog -Message "ISO is already added to VM: $VMName" -Level "INFO"
                return
            }

            Write-EnhancedLog -Message "Adding SCSI controller to VM: $VMName" -Level "INFO"
            Add-VMScsiController -VMName $VMName -ErrorAction Stop

            Write-EnhancedLog -Message "Adding DVD drive with ISO to VM: $VMName" -Level "INFO"
            Add-VMDvdDrive -VMName $VMName -Path $InstallMediaPath -ErrorAction Stop

            Write-EnhancedLog -Message "DVD drive with ISO added to VM: $VMName" -Level "INFO"

            Write-EnhancedLog -Message "Validating the ISO addition for VM: $VMName" -Level "INFO"
            if (-not (Validate-ISOAdded -VMName $VMName -InstallMediaPath $InstallMediaPath)) {
                Write-EnhancedLog -Message "Failed to validate the ISO addition for VM: $VMName" -Level "ERROR"
                throw "ISO validation failed."
            }
        }
        catch {
            Write-EnhancedLog -Message "An error occurred while adding DVD drive to VM: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Add-DVDDriveToVM function" -Level "INFO"
    }
}
