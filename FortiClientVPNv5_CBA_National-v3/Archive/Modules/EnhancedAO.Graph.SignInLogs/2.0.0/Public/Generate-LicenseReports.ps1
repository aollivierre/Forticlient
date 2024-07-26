# Function to generate reports based on user licenses
function Generate-LicenseReports {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.List[PSCustomObject]]$Results,
        [Parameter(Mandatory = $true)]
        [string]$PSScriptRoot,
        [Parameter(Mandatory = $true)]
        [string]$ExportsFolderName
    )

    # Remove duplicates based on UserEntraID
    $uniqueResults = $Results | Sort-Object -Property UserEntraID -Unique

    # Generate reports for users with and without Business Premium licenses
    $premiumLicenses = $uniqueResults | Where-Object { $_.UserLicense -eq 'Microsoft 365 Business Premium' }
    $nonPremiumLicenses = $uniqueResults | Where-Object { $_.UserLicense -ne 'Microsoft 365 Business Premium' }

    $premiumLicenses | Export-Csv "$PSScriptRoot/$ExportsFolderName/Report_PremiumLicenses.csv" -NoTypeInformation
    $nonPremiumLicenses | Export-Csv "$PSScriptRoot/$ExportsFolderName/Report_NonPremiumLicenses.csv" -NoTypeInformation

    # Output totals to console
    Write-EnhancedLog -Message "Total users with Business Premium licenses: $($premiumLicenses.Count)" -Level "INFO"
    Write-EnhancedLog -Message "Total users without Business Premium licenses: $($nonPremiumLicenses.Count)" -Level "INFO"

    Write-EnhancedLog -Message "Generated reports for users with and without Business Premium licenses." -Level "INFO"
}

# # Example usage
# $Json = @() # Your JSON data here
# $Headers = @{} # Your actual headers
# $PSScriptRoot = "C:\Path\To\ScriptRoot" # Update to your script root path
# $ExportsFolderName = "CustomExports"

# $results = Process-AllDevices -Json $Json -Headers $Headers

# # Generate and export the reports
# Generate-LicenseReports -Results $results -PSScriptRoot $PSScriptRoot -ExportsFolderName $ExportsFolderName
