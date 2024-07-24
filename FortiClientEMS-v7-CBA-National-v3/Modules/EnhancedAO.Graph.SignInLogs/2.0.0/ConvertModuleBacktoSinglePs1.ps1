# # Define the paths
# $rootPath = 'C:\Code\Modules\EnhancedAO.Graph.SignInLogs\2.0.0'
# $privatePath = Join-Path -Path $rootPath -ChildPath 'Private'
# $publicPath = Join-Path -Path $rootPath -ChildPath 'Public'
# $outputFile = Join-Path -Path $rootPath -ChildPath 'CombinedScript.ps1'

# # Initialize the output file
# New-Item -Path $outputFile -ItemType File -Force

# # Function to combine files from a directory
# function Combine-Files {
#     param (
#         [string]$directory
#     )
#     Get-ChildItem -Path $directory -Filter *.ps1 | ForEach-Object {
#         Get-Content -Path $_.FullName | Add-Content -Path $outputFile
#         Add-Content -Path $outputFile -Value "`n"  # Add a new line for separation
#     }
# }

# # Combine files from Private and Public folders
# Combine-Files -directory $privatePath
# Combine-Files -directory $publicPath

# Write-Host "All files have been combined into $outputFile"
