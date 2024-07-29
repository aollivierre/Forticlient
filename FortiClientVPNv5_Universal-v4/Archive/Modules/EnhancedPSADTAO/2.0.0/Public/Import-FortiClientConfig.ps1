function Import-FortiClientConfig {
    [CmdletBinding()]
    param (
        [string]$ScriptRoot,
        [string]$FortiClientPath,
        [string]$ConfigFileExtension,
        [string]$FCConfigExecutable,
        [string]$ArgumentTemplate
    )

    begin {
        Write-EnhancedLog -Message 'Starting Import-FortiClientConfig function' -Level 'INFO'
        Log-Params -Params $PSCmdlet.MyInvocation.BoundParameters
    }

    process {
        try {
            # Find the configuration file in the root of the script directory
            $xmlConfigFile = Get-ChildItem -Path $ScriptRoot -Filter $ConfigFileExtension | Select-Object -First 1

            if (-not $xmlConfigFile) {
                Write-EnhancedLog -Message "No configuration file found in the script directory: $ScriptRoot" -Level 'ERROR'
                Write-Output "No configuration file found in the script directory: $ScriptRoot"
                return
            }

            # Check if the FortiClient directory exists
            if (-not (Test-Path -Path $FortiClientPath)) {
                Write-EnhancedLog -Message "FortiClient directory not found at path: $FortiClientPath" -Level 'ERROR'
                Write-Output "FortiClient directory not found at path: $FortiClientPath"
                return
            }

            # Set location to FortiClient directory
            Set-Location -Path $FortiClientPath

            # Execute the FCConfig.exe with the specified arguments
            $fcConfigPath = Join-Path -Path $FortiClientPath -ChildPath $FCConfigExecutable
            $arguments = $ArgumentTemplate -replace '{ConfigFilePath}', $xmlConfigFile.FullName
            Start-Process -FilePath $fcConfigPath -ArgumentList $arguments -Wait

            Write-EnhancedLog -Message 'FCConfig process completed' -Level 'INFO'
            Write-Output "FCConfig process completed"
        } catch {
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message 'Import-FortiClientConfig function completed' -Level 'INFO'
    }
}


#   # Example usage of Import-FortiClientConfig function with splatting
#   $importParams = @{
#     ScriptRoot         = $PSScriptRoot
#     FortiClientPath    = "C:\Program Files\Fortinet\FortiClient"
#     ConfigFileExtension = "*.xml"
#     FCConfigExecutable = "FCConfig.exe"
#     ArgumentTemplate   = "-m all -f `{ConfigFilePath}` -o import -i 1"
# }

# # Call the Import-FortiClientConfig function using splatting
# Import-FortiClientConfig @importParams