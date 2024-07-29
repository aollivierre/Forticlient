# function Download-PSAppDeployToolkit {
#     [CmdletBinding()]
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$Url,

#         [Parameter(Mandatory = $true)]
#         [string]$Destination,

#         [Parameter(Mandatory = $true)]
#         [string]$ToolkitFolder
#     )

#     Begin {
#         Write-EnhancedLog -Message "Starting Download-PSAppDeployToolkit function" -Level "INFO"
#         Log-Params -Params @{
#             Url = $Url
#             Destination = $Destination
#             ToolkitFolder = $ToolkitFolder
#         }
#     }

#     Process {
#         try {
#             # Download and extract PSAppDeployToolkit
#             Invoke-WebRequest -Uri $Url -OutFile $Destination
#             Expand-Archive -Path $Destination -DestinationPath $ToolkitFolder -Force
#         } catch {
#             Write-EnhancedLog -Message "An error occurred while processing the Download-PSAppDeployToolkit function: $($_.Exception.Message)" -Level "ERROR"
#             Handle-Error -ErrorRecord $_
#         }
#     }

#     End {
#         Write-EnhancedLog -Message "Exiting Download-PSAppDeployToolkit function" -Level "INFO"
#     }
# }

# # Example usage
# # Download-PSAppDeployToolkit -Url 'https://github.com/PSAppDeployToolkit/PSAppDeployToolkit/releases/download/v3.8.4/PSAppDeployToolkit_v3.8.4.zip' -Destination 'C:\YourPath\Files\PSAppDeployToolkit.zip' -ToolkitFolder 'C:\YourPath\Toolkit'
