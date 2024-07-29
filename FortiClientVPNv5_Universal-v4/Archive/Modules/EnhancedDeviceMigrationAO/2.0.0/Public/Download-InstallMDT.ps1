# function Download-InstallMDT {
#     [CmdletBinding()]
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$Url,

#         [Parameter(Mandatory = $true)]
#         [string]$Destination,

#         [Parameter(Mandatory = $true)]
#         [string]$FilesFolder
#     )

#     Begin {
#         Write-EnhancedLog -Message "Starting Download-Install-MDT function" -Level "INFO"
#         Log-Params -Params @{
#             Url = $Url
#             Destination = $Destination
#             FilesFolder = $FilesFolder
#         }
#     }

#     Process {
#         try {
#             # Download and install Microsoft Deployment Toolkit
#             Invoke-WebRequest -Uri $Url -OutFile $Destination
#             Start-Process -FilePath $Destination -ArgumentList "/quiet" -Wait

#             # Copy ServiceUI.exe to Files folder
#             Copy-Item -Path "C:\Program Files\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x64\ServiceUI.exe" -Destination $FilesFolder
#         } catch {
#             Write-EnhancedLog -Message "An error occurred while processing the Download-InstallMDT function: $($_.Exception.Message)" -Level "ERROR"
#             Handle-Error -ErrorRecord $_
#         }
#     }

#     End {
#         Write-EnhancedLog -Message "Exiting Download-Install-MDT function" -Level "INFO"
#     }
# }

# # Example usage
# # Download-InstallMDT -Url 'https://download.microsoft.com/download/9/e/1/9e1e94ec-5463-46b7-9f3c-b225034c3a70/MDT_KB4564442.exe' -Destination 'C:\YourPath\Files\MDT.exe' -FilesFolder 'C:\YourPath\Files'
