function Export-SignInLogs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptRoot,
        [Parameter(Mandatory = $true)]
        [string]$ExportsFolderName,
        [Parameter(Mandatory = $true)]
        [string]$ExportSubFolderName,
        [Parameter(Mandatory = $true)]
        [hashtable]$headers,
        [Parameter(Mandatory = $true)]
        [string]$url
    
    )

    # Ensure the exports folder is clean before exporting
    $exportFolder = Ensure-ExportsFolder -BasePath $ScriptRoot -ExportsFolderName $ExportsFolderName -ExportSubFolderName $ExportSubFolderName

    # Get the sign-in logs (assuming you have a way to fetch these logs)
    # $signInLogs = Get-SignInLogs # Replace with the actual command to get sign-in logs

    $signInLogs = Get-SignInLogs -url $url -Headers $headers

    # Check if there are no sign-in logs
    if ($signInLogs.Count -eq 0) {
        Write-EnhancedLog -Message "NO sign-in logs found." -Level "WARNING"
        return
    }

    # Generate a timestamp for the export
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $baseOutputPath = Join-Path -Path $exportFolder -ChildPath "SignInLogs_$timestamp"

    # Setup parameters for Export-Data using splatting
    $exportParams = @{
        Data             = $signInLogs
        BaseOutputPath   = $baseOutputPath
        # IncludeCSV       = $true
        IncludeJSON      = $true
        # IncludeXML       = $true
        # IncludePlainText = $true
        # IncludeExcel     = $true
        # IncludeYAML      = $true
    }

    # Call the Export-Data function with splatted parameters
    Export-Data @exportParams
    Write-EnhancedLog -Message "Data export completed successfully." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
}


# # Define the root path where the scripts and exports are located
# $scriptRoot = "C:\MyScripts"

# # Optionally, specify the names for the exports folder and subfolder
# $exportsFolderName = "CustomExports"
# $exportSubFolderName = "CustomSignInLogs"

# # Call the function to export sign-in logs to XML (and other formats)
# Export-SignInLogsToXML -ScriptRoot $scriptRoot -ExportsFolderName $exportsFolderName -ExportSubFolderName $exportSubFolderName
