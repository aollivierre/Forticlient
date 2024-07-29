# function Install-RequiredModules {

#     [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

#     # $requiredModules = @("Microsoft.Graph", "Microsoft.Graph.Authentication")
#     $requiredModules = @("Microsoft.Graph.Authentication")

#     foreach ($module in $requiredModules) {
#         if (!(Get-Module -ListAvailable -Name $module)) {

#             Write-EnhancedLog -Message "Installing module: $module" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)
#             Install-Module -Name $module -Force
#             Write-EnhancedLog -Message "Module: $module has been installed" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)
#         }
#         else {
#             Write-EnhancedLog -Message "Module $module is already installed" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)
#         }
#     }


#     $ImportedModules = @("Microsoft.Graph.Identity.DirectoryManagement", "Microsoft.Graph.Authentication")
    
#     foreach ($Importedmodule in $ImportedModules) {
#         if ((Get-Module -ListAvailable -Name $Importedmodule)) {
#             Write-EnhancedLog -Message "Importing module: $Importedmodule" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)
#             Import-Module -Name $Importedmodule
#             Write-EnhancedLog -Message "Module: $Importedmodule has been Imported" -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)
#         }
#     }


# }