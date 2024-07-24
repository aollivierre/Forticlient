function EnableVMTPM {
    <#
    .SYNOPSIS
    Enables TPM for the specified VM.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$VMName
    )

    Begin {
        Write-EnhancedLog -Message "Starting Enable-VMTPM function" -Level "INFO"
        Log-Params -Params @{ VMName = $VMName }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Retrieving HGS Guardian" -Level "INFO"
            $owner = Get-HgsGuardian -Name "UntrustedGuardian"

            Write-EnhancedLog -Message "Creating new HGS Key Protector" -Level "INFO"
            $kp = New-HgsKeyProtector -Owner $owner -AllowUntrustedRoot

            Write-EnhancedLog -Message "Setting VM Key Protector for VM: $VMName" -Level "INFO"
            Set-VMKeyProtector -VMName $VMName -KeyProtector $kp.RawData

            Write-EnhancedLog -Message "Enabling TPM for VM: $VMName" -Level "INFO"
            Enable-VMTPM -VMName $VMName

            Write-EnhancedLog -Message "TPM enabled for $VMName" -Level "INFO"
        } catch {
            Write-EnhancedLog -Message "An error occurred while enabling TPM for VM $VMName $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Enable-VMTPM function" -Level "INFO"
    }
}
