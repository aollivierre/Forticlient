function Validate-ISOAdded {
    <#
    .SYNOPSIS
    Validates if the specified ISO file is added to the VM.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $true)]
        [string]$InstallMediaPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Validate-ISOAdded function" -Level "INFO"
        Log-Params -Params @{ VMName = $VMName; InstallMediaPath = $InstallMediaPath }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Retrieving DVD drive information for VM: $VMName" -Level "INFO"
            $dvdDrive = Get-VMDvdDrive -VMName $VMName -ErrorAction SilentlyContinue

            if ($dvdDrive -and ($dvdDrive.Path -eq $InstallMediaPath)) {
                Write-EnhancedLog -Message "ISO is correctly added to VM: $VMName" -Level "INFO" -ForegroundColor Green
                return $true
            } else {
                Write-EnhancedLog -Message "ISO is not added to VM: $VMName" -Level "WARNING" -ForegroundColor Red
                return $false
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while validating ISO addition: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            return $false
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Validate-ISOAdded function" -Level "INFO"
    }
}
