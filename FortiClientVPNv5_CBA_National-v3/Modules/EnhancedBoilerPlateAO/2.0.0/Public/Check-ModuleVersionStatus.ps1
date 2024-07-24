
function Check-ModuleVersionStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$ModuleNames
    )

    #the following modules PowerShellGet and PackageManagement has to be either automatically imported or manually imported into C:\windows\System32\WindowsPowerShell\v1.0\Modules

    Import-Module -Name PowerShellGet -ErrorAction SilentlyContinue
    # Import-Module 'C:\Program Files (x86)\WindowsPowerShell\Modules\PowerShellGet\PSModule.psm1' -ErrorAction SilentlyContinue
    # Import-Module 'C:\windows\System32\WindowsPowerShell\v1.0\Modules\PowerShellGet\PSModule.psm1' -ErrorAction SilentlyContinue
    # Import-Module 'C:\Program Files (x86)\WindowsPowerShell\Modules\PackageManagement\PackageProviderFunctions.psm1' -ErrorAction SilentlyContinue
    # Import-Module 'C:\windows\System32\WindowsPowerShell\v1.0\Modules\PackageManagement\PackageProviderFunctions.psm1' -ErrorAction SilentlyContinue
    # Import-Module 'C:\Program Files (x86)\WindowsPowerShell\Modules\PackageManagement\PackageManagement.psm1' -ErrorAction SilentlyContinue

    $results = New-Object System.Collections.Generic.List[PSObject]  # Initialize a List to hold the results

    foreach ($ModuleName in $ModuleNames) {
        try {

            Write-Host 'Checking module '$ModuleName
            $installedModule = Get-Module -ListAvailable -Name $ModuleName | Sort-Object Version -Descending | Select-Object -First 1
            # $installedModule = Check-SystemWideModule -ModuleName 'Pester'
            $latestModule = Find-Module -Name $ModuleName -ErrorAction SilentlyContinue

            if ($installedModule -and $latestModule) {
                if ($installedModule.Version -lt $latestModule.Version) {
                    $results.Add([PSCustomObject]@{
                        ModuleName = $ModuleName
                        Status = "Outdated"
                        InstalledVersion = $installedModule.Version
                        LatestVersion = $latestModule.Version
                    })
                } else {
                    $results.Add([PSCustomObject]@{
                        ModuleName = $ModuleName
                        Status = "Up-to-date"
                        InstalledVersion = $installedModule.Version
                        LatestVersion = $installedModule.Version
                    })
                }
            } elseif (-not $installedModule) {
                $results.Add([PSCustomObject]@{
                    ModuleName = $ModuleName
                    Status = "Not Installed"
                    InstalledVersion = $null
                    LatestVersion = $null
                })
            } else {
                $results.Add([PSCustomObject]@{
                    ModuleName = $ModuleName
                    Status = "Not Found in Gallery"
                    InstalledVersion = $null
                    LatestVersion = $null
                })
            }
        } catch {
            Write-Error "An error occurred checking module '$ModuleName': $_"
        }
    }

    return $results
}

# Example usage:
# $versionStatuses = Check-ModuleVersionStatus -ModuleNames @('Pester', 'AzureRM', 'PowerShellGet')
# $versionStatuses | Format-Table -AutoSize  # Display the results in a table format for readability


