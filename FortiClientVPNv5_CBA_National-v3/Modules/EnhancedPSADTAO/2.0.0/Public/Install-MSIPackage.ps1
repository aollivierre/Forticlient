function Install-MsiPackage {
    [CmdletBinding()]
    param (
        [string]$ScriptRoot,
        [string]$MsiFileName,
        [string]$FilePath,
        [string]$ArgumentTemplate
    )

    begin {
        Write-EnhancedLog -Message "Starting Install-MsiPackage function for: $MsiFileName" -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            $installerPath = Join-Path -Path $ScriptRoot -ChildPath $MsiFileName
            
            if (Test-Path $installerPath) {
                Write-EnhancedLog -Message "Found installer file: $installerPath" -Level 'INFO'
                $arguments = $ArgumentTemplate -replace '{InstallerPath}', $installerPath
                Start-Process -FilePath $FilePath -ArgumentList $arguments -Wait
                Write-EnhancedLog -Message "Installation process completed for: $installerPath" -Level 'INFO'
                Write-Output "Installation process completed for: $installerPath"
            } else {
                Write-EnhancedLog -Message "Installer file not found at path: $installerPath" -Level 'ERROR'
                Write-Output "Installer file not found at path: $installerPath"
            }
        } catch {
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'Install-MsiPackage function completed' -Level 'INFO'
    }
}

# # Example usage of Install-MsiPackage function with splatting
# $params = @{
#     ScriptRoot       = $PSScriptRoot
#     MsiFileName      = 'FortiClient.msi'
#     FilePath         = 'MsiExec.exe'
#     ArgumentTemplate = "/i `{InstallerPath}` /quiet /norestart"
# }
# Install-MsiPackage @params
