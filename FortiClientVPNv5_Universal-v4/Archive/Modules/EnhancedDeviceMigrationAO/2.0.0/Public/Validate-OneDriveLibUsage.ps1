function Validate-OneDriveLibUsage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OneDriveLibPath
    )

    $processesUsingLib = [System.Collections.Generic.List[PSCustomObject]]::new()

    try {
        # Get all processes
        $processes = Get-Process

        # Iterate over each process and check if it has loaded OneDriveLib.dll
        foreach ($process in $processes) {
            try {
                $modules = $process.Modules | Where-Object { $_.FileName -eq $OneDriveLibPath }
                if ($modules) {
                    $processesUsingLib.Add([PSCustomObject]@{
                        ProcessName = $process.ProcessName
                        ProcessId   = $process.Id
                    })
                }
            }
            catch {
                # Handle any errors encountered while accessing process modules
                Write-EnhancedLog -Message "Could not access modules for process: $($process.ProcessName) (ID: $($process.Id)). Error: $($_.Exception.Message)" -Level "WARNING"
            }
        }
    }
    catch {
        Write-EnhancedLog -Message "An error occurred in Validate-OneDriveLibUsage function: $($_.Exception.Message)" -Level "ERROR"
        Handle-Error -ErrorRecord $_
    }

    return $processesUsingLib
}
