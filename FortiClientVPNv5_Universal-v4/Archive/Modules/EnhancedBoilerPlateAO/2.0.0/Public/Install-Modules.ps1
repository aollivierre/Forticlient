function Install-Modules {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Modules
    )

    # Check if running in PowerShell 5 or in a Windows environment
    # if ($PSVersionTable.PSVersion.Major -eq 5 -or ($PSVersionTable.Platform -eq 'Win32NT' -or [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT)) {
    #     # Install the NuGet package provider if the condition is met
    #     Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser
    # }

    if ($PSVersionTable.PSVersion.Major -eq 5) {
        # Install the NuGet package provider if the condition is met
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser
    }

    
    foreach ($module in $Modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            # Install-Module -Name $module -Force -Scope AllUsers
            Install-Module -Name $module -Force -Scope CurrentUser
            Write-EnhancedLog -Message "Module '$module' installed." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
        }
        else {
            Write-EnhancedLog -Message "Module '$module' is already installed." -Level "INFO" -ForegroundColor ([ConsoleColor]::Yellow)
        }
    }
}