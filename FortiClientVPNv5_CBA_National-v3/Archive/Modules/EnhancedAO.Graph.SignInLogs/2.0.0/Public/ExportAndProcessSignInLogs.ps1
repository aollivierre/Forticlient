function ExportAndProcessSignInLogs {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptRoot,
        [Parameter(Mandatory = $true)]
        [string]$ExportsFolderName,
        [Parameter(Mandatory = $true)]
        [string]$ExportSubFolderName,
        [Parameter(Mandatory = $true)]
        [string]$url,
        [Parameter(Mandatory = $true)]
        [hashtable]$Headers
    )

    try {
        $ExportSignInLogsparams = @{
            ScriptRoot         = $ScriptRoot
            ExportsFolderName  = $ExportsFolderName
            ExportSubFolderName= $ExportSubFolderName
            url                = $url
            Headers            = $Headers
        }
        
        # Call the function with splatted parameters
        # (uncomment if you want to export fresh sign-in logs to a new JSON file)
        # Export-SignInLogs @ExportSignInLogsparams

        $subFolderPath = Join-Path -Path $ScriptRoot -ChildPath $ExportsFolderName
        $subFolderPath = Join-Path -Path $subFolderPath -ChildPath $ExportSubFolderName

        Write-EnhancedLog -Message "Looking for JSON files in $subFolderPath" -Level "DEBUG"

        $latestJsonFile = Find-LatestJsonFile -Directory $subFolderPath

        if ($latestJsonFile) {
            Write-EnhancedLog -Message "Latest JSON file found: $latestJsonFile" -Level "DEBUG"
            $signInLogs = Load-SignInLogs -JsonFilePath $latestJsonFile
            # $dbg
            if ($signInLogs.Count -gt 0) {
                Write-EnhancedLog -Message "Sign-in logs found in $latestJsonFile. Starting to process it" -Level "INFO"
                # Process-AllDevices -Json $signInLogs -Headers $Headers
                return $signInLogs
            } else {
                Write-EnhancedLog -Message "No sign-in logs found in $latestJsonFile." -Level "WARNING"
                return @()
            }
        } else {
            Write-EnhancedLog -Message "No JSON file found to load sign-in logs." -Level "WARNING"
            return @()
        }
    } catch {
        Handle-Error -ErrorRecord $_
        return @()
    }
}
# # Example usage
# $params = @{
#     ScriptRoot         = "C:\Path\To\ScriptRoot"
#     ExportsFolderName  = "Exports"
#     ExportSubFolderName= "SubFolder"
#     url                = "https://example.com/api/signinlogs"
#     Headers            = @{
#         "Authorization" = "Bearer <your_token>"
#         "Content-Type"  = "application/json"
#     }
# }

# ExportAndProcessSignInLogs @params
