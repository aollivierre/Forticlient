function Enter-SafeModeBasedOnDetection {
    [CmdletBinding()]
    param (
        [string]$RegistryPath,
        [string]$BCDeditPath,
        [string]$ArgumentTemplate
    )

    begin {
        Write-EnhancedLog -Message 'Starting Enter-SafeModeBasedOnDetection function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            # Detect system mode
            $params = @{
                RegistryPath = $RegistryPath
            }
            Detect-SystemMode @params

            if ($Global:SystemMode -eq "Normal Mode") {
                # Construct the arguments
                $arguments = $ArgumentTemplate

                # Execute the bcdedit command to enable Safe Mode
                Write-EnhancedLog -Message "Executing bcdedit with arguments: $arguments" -Level 'INFO'
                Start-Process -FilePath $BCDeditPath -ArgumentList $arguments -Wait

                Write-EnhancedLog -Message 'Successfully set the system to boot into Safe Mode on next restart' -Level 'INFO'
            } else {
                Write-EnhancedLog -Message 'System is already in Safe Mode' -Level 'INFO'
            }
        } catch {
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'Enter-SafeModeBasedOnDetection function completed' -Level 'INFO'
    }
}

# # Example usage of Enter-SafeModeBasedOnDetection function with splatting
# $params = @{
#     RegistryPath    = 'HKLM:\SYSTEM\CurrentControlSet\Control\SafeBoot\Option'
#     BCDeditPath     = 'bcdedit.exe'
#     ArgumentTemplate = '/set {current} safeboot minimal'
# }

# # Call the Enter-SafeModeBasedOnDetection function using splatting
# Enter-SafeModeBasedOnDetection @params
