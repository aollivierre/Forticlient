function Detect-FortiClientEMSInstallation {
    <#
    .SYNOPSIS
    Checks for FortiClientEMS installation and version.
    .PARAMETER RegistryPaths
    An array of registry paths to check.
    .PARAMETER SoftwareName
    The name of the software to search for.
    .PARAMETER ExcludedVersion
    The version of the software to exclude.
    .OUTPUTS
    A hashtable indicating whether the software is installed and its version.
    #>
    [CmdletBinding()]
    param (
        [string[]]$RegistryPaths,
        [string]$SoftwareName,
        [version]$ExcludedVersion
    )

    foreach ($path in $RegistryPaths) {
        $items = Get-ChildItem -Path $path -ErrorAction SilentlyContinue

        foreach ($item in $items) {
            $app = Get-ItemProperty -Path $item.PsPath -ErrorAction SilentlyContinue
            if ($app.DisplayName -like "*$SoftwareName*") {
                $installedVersion = New-Object Version $app.DisplayVersion
                if ($installedVersion -lt $ExcludedVersion) {
                    return @{
                        IsInstalled = $true
                        Version = $app.DisplayVersion
                        ProductCode = $app.PSChildName
                    }
                }
            }
        }
    }

    return @{IsInstalled = $false}
}
