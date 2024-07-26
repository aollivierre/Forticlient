function Import-Modules {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Modules
    )
    
    foreach ($module in $Modules) {
        if (Get-Module -ListAvailable -Name $module) {
            # Import-Module -Name $module -Force -Verbose
            Import-Module -Name $module -Force:$true -Global:$true
            Write-EnhancedLog -Message "Module '$module' imported." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
        }
        else {
            Write-EnhancedLog -Message "Module '$module' not found. Cannot import." -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        }
    }
}