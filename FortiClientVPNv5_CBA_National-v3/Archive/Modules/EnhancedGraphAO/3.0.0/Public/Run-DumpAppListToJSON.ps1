
function Run-DumpAppListToJSON {
    param (
        [string]$JsonPath
    )

    $scriptContent = @"
function Dump-AppListToJSON {
    param (
        [string]`$JsonPath
    )


    Disconnect-MgGraph

    # Connect to Graph interactively
    Connect-MgGraph -Scopes 'Application.ReadWrite.All'

    # Retrieve all application objects
    `$allApps = Get-MgApplication

    # Export to JSON
    `$allApps | ConvertTo-Json -Depth 10 | Out-File -FilePath `$JsonPath
}

# Dump application list to JSON
Dump-AppListToJSON -JsonPath `"$JsonPath`"
"@

    # Write the script content to a temporary file
    $tempScriptPath = [System.IO.Path]::Combine($PSScriptRoot, "DumpAppListTemp.ps1")
    Set-Content -Path $tempScriptPath -Value $scriptContent

    # Start a new PowerShell session to run the script and wait for it to complete
    $process = Start-Process pwsh -ArgumentList "-NoProfile", "-NoLogo", "-File", $tempScriptPath -PassThru
    $process.WaitForExit()

    # Remove the temporary script file after execution
    Remove-Item -Path $tempScriptPath
}