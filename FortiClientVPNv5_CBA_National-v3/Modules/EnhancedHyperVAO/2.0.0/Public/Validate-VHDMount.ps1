function Validate-VHDMount {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$VHDXPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Validate-VHDMount function" -Level "INFO"
        Log-Params -Params @{ VHDXPath = $VHDXPath }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Checking if the VHDX is mounted: $VHDXPath" -Level "INFO"
            $vhd = Get-VHD -Path $VHDXPath -ErrorAction SilentlyContinue
            
            if ($null -eq $vhd) {
                Write-EnhancedLog -Message "Get-VHD did not return any information for the path: $VHDXPath" -Level "INFO" -ForegroundColor Red
                return $false
            }

            Write-EnhancedLog -Message "Get-VHD output: $($vhd | Format-List | Out-String)" -Level "DEBUG"

            if ($vhd.Attached) {
                Write-EnhancedLog -Message "VHDX is mounted: $VHDXPath" -Level "INFO" -ForegroundColor Green
                return $true
            } else {
                Write-EnhancedLog -Message "VHDX is not mounted: $VHDXPath" -Level "INFO" -ForegroundColor Red
                return $false
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while validating VHD mount status: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
            return $false
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Validate-VHDMount function" -Level "INFO"
    }
}