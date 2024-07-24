# # Import the module
# Import-Module Microsoft.Graph.Applications

# # Connect to Microsoft Graph
# Connect-MgGraph -Scopes "Application.ReadWrite.All"

# # Get and remove applications starting with 'GraphApp-Test001'
# Get-MgApplication -Filter "startswith(displayName, 'GraphApp-Test001')" | ForEach-Object {
#     Remove-MgApplication -ApplicationId $_.Id -Confirm:$false
# }

# # Disconnect the session
# Disconnect-MgGraph
