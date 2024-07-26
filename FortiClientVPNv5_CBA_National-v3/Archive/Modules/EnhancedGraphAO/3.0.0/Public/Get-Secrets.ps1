function Get-Secrets {
    <#
.SYNOPSIS
Loads secrets from a JSON file.

.DESCRIPTION
This function reads a JSON file containing secrets and returns an object with these secrets.

.PARAMETER SecretsPath
The path to the JSON file containing secrets. If not provided, the default is "secrets.json" in the same directory as the script.

.EXAMPLE
$secrets = Get-Secrets -SecretsPath "C:\Path\To\secrets.json"

This example loads secrets from the specified JSON file.

.NOTES
If the SecretsPath parameter is not provided, the function assumes the JSON file is named "secrets.json" and is located in the same directory as the script.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        # [string]$SecretsPath = (Join-Path -Path $PSScriptRoot -ChildPath "secrets.json")
        [string]$SecretsPath
    )

    try {
        Write-EnhancedLog -Message "Attempting to load secrets from path: $SecretsPath" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)

        # Check if the secrets file exists
        if (-not (Test-Path -Path $SecretsPath)) {
            Write-EnhancedLog -Message "Secrets file not found at path: $SecretsPath" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
            throw "Secrets file not found at path: $SecretsPath"
        }

        # Load and parse the secrets file
        $secrets = Get-Content -Path $SecretsPath -Raw | ConvertFrom-Json
        Write-EnhancedLog -Message "Successfully loaded secrets from path: $SecretsPath" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
        
        return $secrets
    }
    catch {
        Write-EnhancedLog -Message "Error loading secrets from path: $SecretsPath. Error: $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        throw $_
    }
}
