# function Get-ModulesScriptPathsAndVariables {
    

#     <#
#     .SYNOPSIS
#     Dot-sources all PowerShell scripts in the 'Modules' folder relative to the script root.
    
#     .DESCRIPTION
#     This function finds all PowerShell (.ps1) scripts in a 'Modules' folder located in the script root directory and dot-sources them. It logs the process, including any errors encountered, with optional color coding.
    
#     .EXAMPLE
#     Dot-SourceModulesScripts
    
#     Dot-sources all scripts in the 'Modules' folder and logs the process.
    
#     .NOTES
#     Ensure the Write-EnhancedLog function is defined before using this function for logging purposes.
#     #>
#         param (
#             [string]$BaseDirectory
#         )
    
#         try {
#             $ModulesFolderPath = Join-Path -Path $BaseDirectory -ChildPath "Modules"
            
#             if (-not (Test-Path -Path $ModulesFolderPath)) {
#                 throw "Modules folder path does not exist: $ModulesFolderPath"
#             }
    
#             # Construct and return a PSCustomObject
#             return [PSCustomObject]@{
#                 BaseDirectory     = $BaseDirectory
#                 ModulesFolderPath = $ModulesFolderPath
#             }
#         }
#         catch {
#             Write-Host "Error in finding Modules script files: $_" -ForegroundColor Red
#             # Optionally, you could return a PSCustomObject indicating an error state
#             # return [PSCustomObject]@{ Error = $_.Exception.Message }
#         }
#     }