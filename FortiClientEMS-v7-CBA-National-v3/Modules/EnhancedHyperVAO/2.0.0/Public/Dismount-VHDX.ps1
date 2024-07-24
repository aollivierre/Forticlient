function Dismount-VHDX {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$VHDXPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Dismount-VHDX function" -Level "INFO"
        Log-Params -Params @{ VHDXPath = $VHDXPath }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Validating if the VHDX is mounted: $VHDXPath" -Level "INFO"
            $isMounted = Validate-VHDMount -VHDXPath $VHDXPath
            Write-EnhancedLog -Message "Validation result: VHDX is mounted = $isMounted" -Level "INFO"

            if ($isMounted) {
                Write-EnhancedLog -Message "Checking for dependent VMs using the VHDX: $VHDXPath" -Level "INFO"
                $dependentVMs = Get-DependentVMs -VHDXPath $VHDXPath
                $runningVMs = $dependentVMs | Where-Object { $_.State -eq 'Running' }
                
                if ($runningVMs.Count -gt 0) {
                    Write-EnhancedLog -Message "Found running VMs using the VHDX. Skipping dismount." -Level "WARNING"
                    foreach ($vm in $runningVMs) {
                        Write-EnhancedLog -Message "Running dependent VM: $($vm.Name)" -Level "WARNING"
                    }
                    return
                }

                Write-EnhancedLog -Message "No running VMs found using the VHDX. Proceeding with dismount." -Level "INFO"
                Dismount-VHD -Path $VHDXPath -ErrorAction Stop
                Write-EnhancedLog -Message "VHDX dismounted successfully." -Level "INFO"
            } else {
                Write-EnhancedLog -Message "$VHDXPath is already dismounted or not mounted." -Level "INFO"
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while dismounting the VHDX: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Dismount-VHDX function" -Level "INFO"
    }
}
