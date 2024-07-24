function Add-EnvPath {
    <#
    .SYNOPSIS
    Adds a specified path to the environment PATH variable.

    .DESCRIPTION
    The Add-EnvPath function adds a specified path to the environment PATH variable. The path can be added to the session, user, or machine scope.

    .PARAMETER Path
    The path to be added to the environment PATH variable.

    .PARAMETER Container
    Specifies the scope of the environment variable. Valid values are 'Machine', 'User', or 'Session'.

    .EXAMPLE
    Add-EnvPath -Path 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Imaging and Configuration Designer\x86' -Container 'Machine'
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Session')]
        [string] $Container = 'Session'
    )

    begin {
        Write-EnhancedLog -Message "Starting Add-EnvPath function" -Level "INFO"
        Log-Params -Params @{
            Path = $Path
            Container = $Container
        }

        $envPathHashtable = [ordered]@{}
        $persistedPathsHashtable = [ordered]@{}
        $containerMapping = @{
            Machine = [System.EnvironmentVariableTarget]::Machine
            User    = [System.EnvironmentVariableTarget]::User
        }
    }

    process {
        try {
            # Update the PATH variable for User or Machine scope
            if ($Container -ne 'Session') {
                $containerType = $containerMapping[$Container]
                $existingPaths = [System.Environment]::GetEnvironmentVariable('Path', $containerType) -split ';'
                
                foreach ($pathItem in $existingPaths) {
                    $persistedPathsHashtable[$pathItem] = $null
                }

                if (-not $persistedPathsHashtable.Contains($Path)) {
                    Write-EnhancedLog -Message "Path not found in persisted paths, adding it." -Level "INFO"
                    $persistedPathsHashtable[$Path] = $null
                    [System.Environment]::SetEnvironmentVariable('Path', ($persistedPathsHashtable.Keys -join ';'), $containerType)
                }
            }

            # Update the PATH variable for the current session
            $existingSessionPaths = $env:Path -split ';'
            
            foreach ($sessionPathItem in $existingSessionPaths) {
                $envPathHashtable[$sessionPathItem] = $null
            }

            if (-not $envPathHashtable.Contains($Path)) {
                Write-EnhancedLog -Message "Path not found in session paths, adding it." -Level "INFO"
                $envPathHashtable[$Path] = $null
                $env:Path = $envPathHashtable.Keys -join ';'
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    end {
        Write-EnhancedLog -Message "Exiting Add-EnvPath function" -Level "INFO"
        
        Write-Host "The permanent environment PATH variable is:"
        [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine) -split ';'

        Write-Host "The temporary environment PATH variable is:"
        $env:Path -split ';'
    }
}

# # Example usage
# $envPathParams = @{
#     Path = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Imaging and Configuration Designer\x86'
#     Container = 'Machine'
# }

# Add-EnvPath @envPathParams
