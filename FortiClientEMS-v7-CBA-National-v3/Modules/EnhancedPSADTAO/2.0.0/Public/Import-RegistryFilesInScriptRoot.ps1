function Import-RegistryFilesInScriptRoot {
    [CmdletBinding()]
    param (
        [string]$Filter,
        [string]$FilePath,
        [string]$Arguments
    )

    begin {
        Write-EnhancedLog -Message 'Starting Import-RegistryFilesInScriptRoot function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            $scriptDirectory = $PSScriptRoot
            $registryFiles = Get-ChildItem -Path $scriptDirectory -Filter $Filter

            if ($registryFiles.Count -eq 0) {
                Write-EnhancedLog -Message "No registry files found in the directory: $scriptDirectory" -Level 'WARNING'
                return
            }

            foreach ($registryFile in $registryFiles) {
                $registryFilePath = $registryFile.FullName

                if (Test-Path $registryFilePath) {
                    Write-EnhancedLog -Message "Found registry file: $registryFilePath" -Level 'INFO'
                    $startProcessParams = @{
                        FilePath = $FilePath
                        ArgumentList = $Arguments
                        Wait = $true
                    }
                    Start-Process @startProcessParams
                    Write-EnhancedLog -Message "Registry file import process completed for: $registryFilePath" -Level 'INFO'

                    # Validate the registry keys
                    Validate-RegistryKeys -RegistryFilePath $registryFilePath
                }
                else {
                    Write-EnhancedLog -Message "Registry file not found at path: $registryFilePath" -Level 'ERROR'
                }
            }
        }
        catch {
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'Import-RegistryFilesInScriptRoot function completed' -Level 'INFO'
    }
}


# # Define parameters for splatting
# $params = @{
#     Filter  = "*.reg"
#     FilePath = "reg.exe"
#     Args = "import `"$registryFilePath`""
# }

# # Call the Import-RegistryFilesInScriptRoot function using splatting
# Import-RegistryFilesInScriptRoot @params
