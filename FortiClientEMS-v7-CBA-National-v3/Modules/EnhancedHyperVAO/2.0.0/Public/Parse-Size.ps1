function Parse-Size {
    <#
    .SYNOPSIS
    Parses a size string and converts it to bytes.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Size
    )

    Begin {
        Write-EnhancedLog -Message "Starting Parse-Size function" -Level "INFO"
        Log-Params -Params @{ Size = $Size }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Parsing size string: $Size" -Level "INFO"
            switch -regex ($Size) {
                '^(\d+)\s*KB$' {
                    $result = [int64]$matches[1] * 1KB
                    Write-EnhancedLog -Message "Parsed size: $Size to $result bytes" -Level "INFO"
                    return $result
                }
                '^(\d+)\s*MB$' {
                    $result = [int64]$matches[1] * 1MB
                    Write-EnhancedLog -Message "Parsed size: $Size to $result bytes" -Level "INFO"
                    return $result
                }
                '^(\d+)\s*GB$' {
                    $result = [int64]$matches[1] * 1GB
                    Write-EnhancedLog -Message "Parsed size: $Size to $result bytes" -Level "INFO"
                    return $result
                }
                '^(\d+)\s*TB$' {
                    $result = [int64]$matches[1] * 1TB
                    Write-EnhancedLog -Message "Parsed size: $Size to $result bytes" -Level "INFO"
                    return $result
                }
                default {
                    Write-EnhancedLog -Message "Invalid size format: $Size" -Level "ERROR"
                    throw "Invalid size format: $Size"
                }
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while parsing size: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Parse-Size function" -Level "INFO"
    }
}
