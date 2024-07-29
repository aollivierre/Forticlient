# Function to generate a report for PII Removed cases
function Generate-PII-RemovedReport {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.List[PSCustomObject]]$Results,
        [Parameter(Mandatory = $true)]
        [string]$PSScriptRoot,
        [Parameter(Mandatory = $true)]
        [string]$ExportsFolderName
    )

    # Filter results for PII Removed (external) cases
    $piiRemovedResults = $Results | Where-Object { $_.DeviceStateInIntune -eq 'External' }

    # Export the results to a CSV file
    $piiRemovedResults | Export-Csv "$PSScriptRoot/$ExportsFolderName/Report_PIIRemoved.csv" -NoTypeInformation

    # Output totals to console
    Write-EnhancedLog -Message "Total users with PII Removed (external Azure AD/Entra ID tenants): $($piiRemovedResults.Count)" -Level "Warning"
    Write-EnhancedLog -Message "Generated report for users with PII Removed (external Azure AD/Entra ID tenants." -Level "INFO"
}

# # Example usage
# $Json = @() # Your JSON data here
# $Headers = @{} # Your actual headers
# $PSScriptRoot = "C:\Path\To\ScriptRoot" # Update to your script root path
# $ExportsFolderName = "CustomExports"

# $results = Process-AllDevices -Json $Json -Headers $Headers

# # Generate and export the PII Removed report
# Generate-PII-RemovedReport -Results $results -PSScriptRoot $PSScriptRoot -ExportsFolderName $ExportsFolderName
