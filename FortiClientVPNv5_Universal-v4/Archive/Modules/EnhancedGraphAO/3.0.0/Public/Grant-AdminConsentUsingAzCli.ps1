# function Grant-AdminConsentUsingAzCli {
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$AppId
#     )

#     try {
#         Write-EnhancedLog -Message "Granting admin consent to Azure AD application with App ID: $AppId using Azure CLI" -Level "INFO"



#         #First download and install Az CLI

#         # $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; Remove-Item .\AzureCLI.msi


#         # Run the following to fix the issue mentioned here https://github.com/Azure/azure-cli/issues/28997
#         az account clear
#         az config set core.enable_broker_on_windows=false

#         # Now login (it will open up a web browser window to login as normal)
#         #If you have an Azure Subscription
#         # az login


#         #If you DO NOT have an Azure Subscription
#         az login --allow-no-subscriptions

#         # $DBG

#         # Execute the Azure CLI command to grant admin consent
#         $azCliCommand = "az ad app permission admin-consent --id $AppId"
#         $output = Invoke-Expression -Command $azCliCommand

#         # $DBG

#         if ($output -match "deprecated") {
#             Write-EnhancedLog -Message "The 'admin-consent' command is deprecated. Use 'az ad app permission grant' instead." -Level "WARNING"
#         }

#         Write-EnhancedLog -Message "Admin consent granted successfully using Azure CLI." -Level "INFO"

#         az logout

#         return $output

#     } catch {
#         Write-EnhancedLog -Message "An error occurred while granting admin consent using Azure CLI." -Level "ERROR"
#         Handle-Error -ErrorRecord $_
#         throw $_
#     }
# }

# # Example usage
# # Grant-AdminConsentUsingAzCli -AppId "your-application-id"



# #Readme
# # https://github.com/Azure/azure-cli/issues/28997

# # Solution: (After installing azure-cli-2.61.0-x64.msi the az command will become available through the PATH ENV Variable located in C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin now to fix the az login issue mentioned follow these steps carefully

# # Step 1: open CMD or PoweShell 5 or 7 (in VS Code, Terminal or normal Shell) AS Admin
# # Step 2: Run the following command az account clear (you will get nothing back)
# # Step 3: Run the following command az config set core.enable_broker_on_windows=false (you will get "A web browser has been opened at https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize. Please continue the login in the web browser. If no web browser is available or if the web browser fails to open, use device code flow with az login --use-device-code.") and then a web login page will open
# # Step4: Once you login it will say in the webpage

# # You have logged into Microsoft Azure!
# # You can close this window, or we will redirect you to the Azure CLI documentation in 1 minute.



# #Example Output


# # C:\Users\Administrator>az account clear

# # C:\Users\Administrator>az login
# # Please select the account you want to log in with.
# # User cancelled the Accounts Control Operation.. Status: Response_Status.Status_UserCanceled, Error code: 0, Tag: 528315210
# # Please explicitly log in with:
# # az login

# # C:\Users\Administrator>az account clear

# # C:\Users\Administrator>az config set core.enable_broker_on_windows=false
# # Command group 'config' is experimental and under development. Reference and support levels: https://aka.ms/CLI_refstatus

# # C:\Users\Administrator>az login
# # A web browser has been opened at https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize. Please continue the login in the web browser. If no web browser is available or if the web browser fails to open, use device code flow with `az login --use-device-code`.

# # Retrieving tenants and subscriptions for the selection...
# # The following tenants don't contain accessible subscriptions. Use `az login --allow-no-subscriptions` to have tenant level access.
# # 5784dc53-9279-4dc4-8b3d-cf6e8d4f9c50 'CASN'
# # No subscriptions found for NovaAdmin_AOllivierre@casn.ca.

# # C:\Users\Administrator>






# # az login --allow-no-subscriptions                                  in pwsh at 05:40:25
# # A web browser has been opened at https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize. Please continue the login in the web browser. If no web browser is available or if the web browser fails to open, use device code flow with `az login --use-device-code`.

# # Retrieving tenants and subscriptions for the selection...
# # The following tenants don't contain accessible subscriptions. Use `az login --allow-no-subscriptions` to have tenant level access.
# # 5784dc53-9279-4dc4-8b3d-cf6e8d4f9c50 'CASN'

# # [Tenant and subscription selection]

# # No     Subscription name          Subscription ID                       Tenant
# # -----  -------------------------  ------------------------------------  ------------------------------------
# # [1] *  N/A(tenant level account)  5784dc53-9279-4dc4-8b3d-cf6e8d4f9c50  5784dc53-9279-4dc4-8b3d-cf6e8d4f9c50

# # The default is marked with an *; the default tenant is '5784dc53-9279-4dc4-8b3d-cf6e8d4f9c50' and subscription is 'N/A(tenant level account)' (5784dc53-9279-4dc4-8b3d-cf6e8d4f9c50).

# # Select a subscription and tenant (Type a number or Enter for no changes): 1

# # Tenant: 5784dc53-9279-4dc4-8b3d-cf6e8d4f9c50
# # Subscription: N/A(tenant level account) (5784dc53-9279-4dc4-8b3d-cf6e8d4f9c50)

# # [Announcements]
# # With the new Azure CLI login experience, you can select the subscription you want to use more easily. Learn more about it and its configuration at https://go.microsoft.com/fwlink/?linkid=2271236

# # If you encounter any problem, please open an issue at https://aka.ms/azclibug

# # [Warning] The login output has been updated. Please be aware that it no longer displays the full list of available subscriptions by default.