# function Import-LatestModulesLocalRepository {

#     <#
# .SYNOPSIS
#     Imports the latest version of all modules found in the specified Modules directory.

# .DESCRIPTION
#     This function scans the Modules directory for module folders, identifies the latest version of each module,
#     and attempts to import the module. If a module file is not found or if importing fails, appropriate error
#     messages are logged.

# .PARAMETER None
#     This function does not take any parameters.

# .NOTES
#     This function assumes the presence of a custom function 'Import-ModuleWithRetry' for retrying module imports.

# .EXAMPLE
#     ImportLatestModules
#     This example imports the latest version of all modules found in the Modules directory.
# #>

#     [CmdletBinding()]
#     param (
#         $ModulesFolderPath
#     )

#     Begin {
#         # Get the path to the Modules directory
#         # $modulesDir = Join-Path -Path $PSScriptRoot -ChildPath "Modules"
#         # $modulesDir = "C:\code\Modules"

#         # Get all module directories
#         $moduleDirectories = Get-ChildItem -Path $ModulesFolderPath -Directory

#         Write-Host "moduleDirectories is $moduleDirectories"

#         # Log the number of discovered module directories
#         Write-Host "Discovered module directories: $($moduleDirectories.Count)"  -ForegroundColor ([ConsoleColor]::Cyan)
#     }

#     Process {
#         foreach ($moduleDir in $moduleDirectories) {
#             # Get the latest version directory for the current module
#             $latestVersionDir = Get-ChildItem -Path $moduleDir.FullName -Directory | Sort-Object Name -Descending | Select-Object -First 1

#             if ($null -eq $latestVersionDir) {
#                 Write-Host "No version directories found for module: $($moduleDir.Name)" -ForegroundColor ([ConsoleColor]::Red)
#                 continue
#             }

#             # Construct the path to the module file
#             $modulePath = Join-Path -Path $latestVersionDir.FullName -ChildPath "$($moduleDir.Name).psm1"

#             # Check if the module file exists
#             if (Test-Path -Path $modulePath) {
#                 # Import the module with retry logic
#                 try {
#                     Import-ModuleWithRetry -ModulePath $modulePath
#                     # Import-Module $ModulePath -ErrorAction Stop -Verbose
#                     Write-Host "Successfully imported module: $($moduleDir.Name) from version: $($latestVersionDir.Name)"  -ForegroundColor ([ConsoleColor]::Green)
#                 }
#                 catch {
#                     Write-Host "Failed to import module: $($moduleDir.Name) from version: $($latestVersionDir.Name). Error: $_"  -ForegroundColor ([ConsoleColor]::Red)
#                 }
#             }
#             else {
#                 Write-Host  "Module file not found: $modulePath" -ForegroundColor ([ConsoleColor]::Red)
#             }
#         }
#     }

#     End {
#         Write-Host "Module import process completed using Import-LatestModulesLocalRepository from $moduleDirectories" -ForegroundColor ([ConsoleColor]::Cyan)
#     }
# }




function Import-LatestModulesLocalRepository {
    <#
.SYNOPSIS
    Imports the latest version of all modules found in the specified Modules directory.

.DESCRIPTION
    This function scans the Modules directory for module folders, identifies the latest version of each module,
    and attempts to import the module. If a module file is not found or if importing fails, appropriate error
    messages are logged.

.PARAMETER ModulesFolderPath
    The path to the folder containing the modules.

.EXAMPLE
    Import-LatestModulesLocalRepository -ModulesFolderPath "C:\code\Modules"
    This example imports the latest version of all modules found in the specified Modules directory.
#>

    [CmdletBinding()]
    param (
        [string]$ModulesFolderPath,
        [string]$ScriptPath
        
    )

    Begin {
        # Get the path to the Modules directory
        $moduleDirectories = Get-ChildItem -Path $ModulesFolderPath -Directory

        Write-Host "moduleDirectories is $moduleDirectories"

        # Log the number of discovered module directories
        Write-Host "Discovered module directories: $($moduleDirectories.Count)" -ForegroundColor ([ConsoleColor]::Cyan)

        # Read the modules exclusion list from the JSON file
        $exclusionFilePath = Join-Path -Path $ScriptPath -ChildPath "modulesexclusion.json"
        if (Test-Path -Path $exclusionFilePath) {
            $excludedModules = Get-Content -Path $exclusionFilePath | ConvertFrom-Json
            Write-Host "Excluded modules: $excludedModules" -ForegroundColor ([ConsoleColor]::Cyan)
        } else {
            $excludedModules = @()
            Write-Host "No exclusion file found. Proceeding with all modules." -ForegroundColor ([ConsoleColor]::Yellow)
        }
    }

    Process {
        foreach ($moduleDir in $moduleDirectories) {
            # Skip the module if it is in the exclusion list
            if ($excludedModules -contains $moduleDir.Name) {
                Write-Host "Skipping excluded module: $($moduleDir.Name)" -ForegroundColor ([ConsoleColor]::Yellow)
                continue
            }

            # Get the latest version directory for the current module
            $latestVersionDir = Get-ChildItem -Path $moduleDir.FullName -Directory | Sort-Object Name -Descending | Select-Object -First 1

            if ($null -eq $latestVersionDir) {
                Write-Host "No version directories found for module: $($moduleDir.Name)" -ForegroundColor ([ConsoleColor]::Red)
                continue
            }

            # Construct the path to the module file
            $modulePath = Join-Path -Path $latestVersionDir.FullName -ChildPath "$($moduleDir.Name).psm1"

            # Check if the module file exists
            if (Test-Path -Path $modulePath) {
                # Import the module with retry logic
                try {
                    Import-ModuleWithRetry -ModulePath $modulePath
                    Write-Host "Successfully imported module: $($moduleDir.Name) from version: $($latestVersionDir.Name)" -ForegroundColor ([ConsoleColor]::Green)
                }
                catch {
                    Write-Host "Failed to import module: $($moduleDir.Name) from version: $($latestVersionDir.Name). Error: $_" -ForegroundColor ([ConsoleColor]::Red)
                }
            }
            else {
                Write-Host "Module file not found: $modulePath" -ForegroundColor ([ConsoleColor]::Red)
            }
        }
    }

    End {
        Write-Host "Module import process completed using Import-LatestModulesLocalRepository from $moduleDirectories" -ForegroundColor ([ConsoleColor]::Cyan)
    }
}
