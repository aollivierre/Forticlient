function Invoke-Uninstall {
    [CmdletBinding()]
    param (
        [string]$ProductId,
        [string]$FilePath = 'MsiExec.exe',
        [string]$ArgumentTemplate = "/X{ProductId} /quiet /norestart"
    )

    begin {
        Write-EnhancedLog -Message 'Starting Invoke-Uninstall function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            Write-EnhancedLog -Message 'Starting uninstallation process.' -Level 'INFO'

            # Construct the argument list using the template
            $arguments = $ArgumentTemplate -replace '{ProductId}', $ProductId

            Write-EnhancedLog -Message "FilePath: $FilePath" -Level 'INFO'
            Write-EnhancedLog -Message "Arguments: $arguments" -Level 'INFO'

            Start-Process -FilePath $FilePath -ArgumentList $arguments -Wait -WindowStyle Hidden

            Write-EnhancedLog -Message "Executed uninstallation with arguments: $arguments" -Level 'INFO'
        } catch {
            Write-EnhancedLog -Message "An error occurred during the uninstallation process: $($_.Exception.Message)" -Level 'ERROR'
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'Invoke-Uninstall function completed' -Level 'INFO'
    }
}

# # Example usage of Invoke-Uninstall function with splatting
# $params = @{
#     ProductId = 'YOUR_PRODUCT_ID'
#     FilePath = 'MsiExec.exe'
#     ArgumentTemplate = "/X{ProductId} /quiet /norestart"
# }
# Invoke-Uninstall @params
