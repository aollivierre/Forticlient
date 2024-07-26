function Uninstall-FortiClientEMSAgentApplication {
    [CmdletBinding()]
    param (
        [string[]]$UninstallKeys,
        [string]$ApplicationName,
        [string]$FilePath,
        [string]$ArgumentTemplate
    )

    begin {
        Write-EnhancedLog -Message 'Starting the Uninstall-FortiClientEMSAgentApplication function...' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            $findParams = @{
                UninstallKeys  = $UninstallKeys
                ApplicationName = $ApplicationName
            }
            $productId = Find-UninstallString @findParams

            if ($null -ne $productId) {
                Write-EnhancedLog -Message "Found product ID: $productId" -Level 'INFO'
                
                # Prepare parameters for Invoke-Uninstall
                $invokeParams = @{
                    ProductId        = $productId
                    FilePath         = $FilePath
                    ArgumentTemplate = $ArgumentTemplate
                }
                Invoke-Uninstall @invokeParams
                #wait a bit before going into detection/validation
                Start-Sleep -Seconds 30
            } else {
                Write-EnhancedLog -Message 'Product ID not found for FortiClientEMSAgent application.' -Level 'WARNING'
            }
        } catch {
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'Uninstall process completed.' -Level 'INFO'
    }
}

# # Example usage of Uninstall-FortiClientEMSAgentApplication function with splatting
# $params = @{
#     UninstallKeys = @(
#         'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
#         'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
#     )
#     ApplicationName = '*Forti*'
#     FilePath = 'MsiExec.exe'
#     ArgumentTemplate = "/X{ProductId} /quiet /norestart"
# }
# Uninstall-FortiClientEMSAgentApplication @params
