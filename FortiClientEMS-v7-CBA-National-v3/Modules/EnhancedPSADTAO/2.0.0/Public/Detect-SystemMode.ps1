function Detect-SystemMode {
    [CmdletBinding()]
    param (
        [string]$RegistryPath
    )

    begin {
        Write-EnhancedLog -Message 'Starting Detect-SystemMode function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            $safeMode = Get-ItemProperty -Path $RegistryPath -ErrorAction Stop

            if ($safeMode.Option -eq 1) {
                Write-EnhancedLog -Message "System is in Safe Mode" -Level 'INFO'
                $Global:SystemMode = "Safe Mode"
            } else {
                Write-EnhancedLog -Message "System is in Normal Mode" -Level 'INFO'
                $Global:SystemMode = "Normal Mode"
            }
        } catch {
            Write-EnhancedLog -Message "System is in Normal Mode (SafeBoot key not found)" -Level 'INFO'
            $Global:SystemMode = "Normal Mode"
        }
    }

    end {
        Write-EnhancedLog -Message 'Detect-SystemMode function completed' -Level 'INFO'
    }
}

# # Example usage of Detect-SystemMode function with splatting
# $params = @{
#     RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SafeBoot\Option'
# }

# # Call the Detect-SystemMode function using splatting
# Detect-SystemMode @params

# Access the result
# $SystemMode
