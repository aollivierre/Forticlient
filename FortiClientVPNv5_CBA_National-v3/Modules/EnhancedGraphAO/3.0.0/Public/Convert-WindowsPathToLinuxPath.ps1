function Convert-WindowsPathToLinuxPath {
    <#
.SYNOPSIS
    Converts a Windows file path to a Linux file path.

.DESCRIPTION
    This function takes a Windows file path as input and converts it to a Linux file path.
    It replaces backslashes with forward slashes and handles the drive letter.

.PARAMETER WindowsPath
    The full file path in Windows format that needs to be converted.

.EXAMPLE
    PS> Convert-WindowsPathToLinuxPath -WindowsPath 'C:\Code\CB\Entra\ARH\Get-EntraConnectSyncErrorsfromEntra copy.ps1'
    Returns '/mnt/c/Code/CB/Entra/ARH/Get-EntraConnectSyncErrorsfromEntra copy.ps1'

#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$WindowsPath
    )

    Begin {
        Write-Host "Starting the path conversion process..."
    }

    Process {
        try {
            Write-Host "Input Windows Path: $WindowsPath"
            
            # Replace backslashes with forward slashes
            $linuxPath = $WindowsPath -replace '\\', '/'

            # Handle drive letter by converting "C:" to "/mnt/c"
            if ($linuxPath -match '^[A-Za-z]:') {
                $driveLetter = $linuxPath.Substring(0, 1).ToLower()
                $linuxPath = "/mnt/$driveLetter" + $linuxPath.Substring(2)
            }

            Write-Host "Converted Linux Path: $linuxPath"
            return $linuxPath
        }
        catch {
            Write-Host "Error during conversion: $_"
            throw
        }
    }

    End {
        Write-Host "Path conversion completed."
    }
}

# # Example usage
# $windowsPath = 'C:\Code\Unified365toolbox\Graph\graphcert.pfx'
# $linuxPath = Convert-WindowsPathToLinuxPath -WindowsPath $windowsPath
# Write-Host "Linux path: $linuxPath"
