function Validate-PathExistsWithLogging {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    Begin {
        Write-EnhancedLog -Message "Starting Validate-PathExistsWithLogging function" -Level "INFO"
        Log-Params -Params @{
            Path = $Path
        }
    }

    Process {
        try {
            $exists = Test-Path -Path $Path

            if ($exists) {
                Write-EnhancedLog -Message "Path exists: $Path" -Level "INFO"
            }
            else {
                Write-EnhancedLog -Message "Path does not exist: $Path" -Level "WARNING"
            }

            return $exists
        }
        catch {
            Write-EnhancedLog -Message "Error during path validation: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Validate-PathExistsWithLogging function" -Level "INFO"
    }
}


# $pathExists = Validate-PathExistsWithLogging -Path "C:\Path\To\Check"

