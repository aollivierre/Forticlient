function Exit-SafeModeBasedOnDetection {
    [CmdletBinding()]
    param (
        [string]$RegistryPath,
        [string]$BCDeditPath,
        [string]$ArgumentTemplate
    )

    begin {
        Write-EnhancedLog -Message 'Starting Exit-SafeModeBasedOnDetection function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            # Detect system mode
            $params = @{
                RegistryPath = $RegistryPath
            }
            Detect-SystemMode @params

            if ($Global:SystemMode -eq "Safe Mode") {
                # Construct the arguments
                $arguments = $ArgumentTemplate

                # Execute the bcdedit command to disable Safe Mode
                Write-EnhancedLog -Message "Executing bcdedit with arguments: $arguments" -Level 'INFO'
                Start-Process -FilePath $BCDeditPath -ArgumentList $arguments -Wait

                Write-EnhancedLog -Message 'Successfully set the system to boot into Normal Mode on next restart' -Level 'INFO'
            } else {
                Write-EnhancedLog -Message 'System is already in Normal Mode' -Level 'INFO'
            }
        } catch {
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'Exit-SafeModeBasedOnDetection function completed' -Level 'INFO'
    }
}

# # Example usage of Exit-SafeModeBasedOnDetection function with splatting
# $params = @{
#     RegistryPath    = 'HKLM:\SYSTEM\CurrentControlSet\Control\SafeBoot\Option'
#     BCDeditPath     = 'bcdedit.exe'
#     ArgumentTemplate = '/deletevalue {current} safeboot'
# }

# # Call the Exit-SafeModeBasedOnDetection function using splatting
# Exit-SafeModeBasedOnDetection @params
