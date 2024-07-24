function Upload-Win32App {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Prg,

        [Parameter(Mandatory = $true)]
        [string]$Prg_Path,

        [string]$Prg_img,

        [string]$Win32AppsRootPath,

        [string]$linetoadd,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$config
    )

    Write-EnhancedLog -Message "Entering Upload-Win32App" -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
    Write-EnhancedLog -Message "Uploading: $($Prg.name)" -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)

    $InstallCommandLines = Set-InstallCommandLine -config $config
    Log-Params -Params @{
        Prg      = $Prg
        Prg_Path = $Prg_Path
        Prg_img  = $Prg_img
    }

    $paths = Prepare-Paths -Prg $Prg -Prg_Path $Prg_Path -Win32AppsRootPath $Win32AppsRootPath
    $IntuneWinFile = Create-IntuneWinPackage -Prg $Prg -Prg_Path $Prg_Path -destinationPath $paths.destinationPath

    Upload-IntuneWinPackage -Prg $Prg -Prg_Path $Prg_Path -Prg_img $Prg_img -config $config -IntuneWinFile $IntuneWinFile -InstallCommandLine $InstallCommandLines.InstallCommandLine -UninstallCommandLine $InstallCommandLines.UninstallCommandLine
    # Start-Sleep -Seconds 10

    # Write-EnhancedLog -Message "Calling Create-AADGroup for $($Prg.name)" -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
    # Create-AADGroup -Prg $Prg
    # Write-EnhancedLog -Message "Completed Create-AADGroup for $($Prg.name)" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
}

function Set-InstallCommandLine {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$config
    )

    if ($config.serviceUIPSADT -eq $true) {
        $InstallCommandLine = "ServiceUI.exe -process:explorer.exe Deploy-Application.exe -DeploymentType install"
        $UninstallCommandLine = "ServiceUI.exe -process:explorer.exe Deploy-Application.exe -DeploymentType Uninstall"
    }
    elseif ($config.PSADT -eq $true) {
        $InstallCommandLine = "Deploy-Application.exe -DeploymentType install -DeployMode Silent"
        $UninstallCommandLine = "Deploy-Application.exe -DeploymentType Uninstall -DeployMode Silent"
    }
    else {
        $InstallCommandLine = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -command .\install.ps1"
        $UninstallCommandLine = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -command .\uninstall.ps1"
    }

    return @{
        InstallCommandLine   = $InstallCommandLine
        UninstallCommandLine = $UninstallCommandLine
    }
}

function Prepare-Paths {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Prg,

        [Parameter(Mandatory = $true)]
        [string]$Prg_Path,

        [Parameter(Mandatory = $true)]
        [string]$Win32AppsRootPath
    )

    if (-not (Test-Path -Path $Prg_Path)) {
        Write-EnhancedLog -Message "Source path $Prg_Path does not exist. Creating it." -Level "INFO" -ForegroundColor ([ConsoleColor]::Yellow)
        New-Item -Path $Prg_Path -ItemType Directory -Force
    }
    
    $destinationRootPath = Join-Path -Path $Win32AppsRootPath -ChildPath "Win32Apps"
    if (-not (Test-Path -Path $destinationRootPath)) {
        New-Item -Path $destinationRootPath -ItemType Directory -Force
    }

    $destinationPath = Join-Path -Path $destinationRootPath -ChildPath $Prg.name
    if (-not (Test-Path -Path $destinationPath)) {
        New-Item -Path $destinationPath -ItemType Directory -Force
    }

    Write-EnhancedLog -Message "Destination path created: $destinationPath" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
    return @{
        destinationPath = $destinationPath
    }
}

function Create-IntuneWinPackage {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Prg,

        [Parameter(Mandatory = $true)]
        [string]$Prg_Path,

        [Parameter(Mandatory = $true)]
        [string]$destinationPath
    )
    try {
        Write-EnhancedLog -Message "Creating .intunewin package..." -Level "INFO" -ForegroundColor ([ConsoleColor]::Cyan)

        $setupFile = "install.ps1"
        # $Win32AppPackage = New-IntuneWin32AppPackage -SourceFolder $Prg_Path -SetupFile $setupFile -OutputFolder $destinationPath -Verbose -Force:$true

        # using New-IntuneWinPackage instead of New-IntuneWin32AppPackage because it creates a .intunewin file in a cross-platform way both on Windows and Linux
        New-IntuneWinPackage -SourcePath $Prg_Path -DestinationPath $destinationPath -SetupFile $setupFile -Verbose
        # Write-Host "Package creation completed successfully." -ForegroundColor Green
        Write-EnhancedLog -Message "Package creation completed successfully." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)

        $IntuneWinFile = Join-Path -Path $destinationPath -ChildPath "install.intunewin"
        
        # $IntuneWinFile = $Win32AppPackage.Path
        Write-EnhancedLog -Message "IntuneWinFile path set: $IntuneWinFile" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
        return $IntuneWinFile
    }
    catch {
        Write-EnhancedLog -Message "Error creating .intunewin package: $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        Write-Host "Error creating .intunewin package: $_" -ForegroundColor Red
        exit
    }
}

function Upload-IntuneWinPackage {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Prg,

        [Parameter(Mandatory = $true)]
        [string]$Prg_Path,

        [Parameter(Mandatory = $true)]
        [string]$Prg_img,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$config,

        [Parameter(Mandatory = $true)]
        [string]$IntuneWinFile,

        [Parameter(Mandatory = $true)]
        [string]$InstallCommandLine,

        [Parameter(Mandatory = $true)]
        [string]$UninstallCommandLine
    )

    try {
        $DisplayName = "$($Prg.Name)"
        Write-EnhancedLog -Message "DisplayName set: $DisplayName" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)

        $DetectionRule = Create-DetectionRule -Prg_Path $Prg_Path
        $RequirementRule = Create-RequirementRule
        $Icon = Set-AppIcon -Prg_img $Prg_img

        $IntuneAppParams = @{
            FilePath                 = $IntuneWinFile
            Icon                     = $Icon
            DisplayName              = "$DisplayName ($($config.InstallExperience))"
            Description              = "$DisplayName ($($config.InstallExperience))"
            Publisher                = $config.Publisher
            AppVersion               = $config.AppVersion
            Developer                = $config.Developer
            Owner                    = $config.Owner
            CompanyPortalFeaturedApp = [System.Convert]::ToBoolean($config.CompanyPortalFeaturedApp)
            InstallCommandLine       = $InstallCommandLine
            UninstallCommandLine     = $UninstallCommandLine
            InstallExperience        = $config.InstallExperience
            RestartBehavior          = $config.RestartBehavior
            DetectionRule            = $DetectionRule
            RequirementRule          = $RequirementRule
            InformationURL           = $config.InformationURL
            PrivacyURL               = $config.PrivacyURL
            Verbose                  = $true
        }

        # Log-Params -Params $IntuneAppParams

        # Create a copy of $IntuneAppParams excluding the $Icon
        $IntuneAppParamsForLogging = $IntuneAppParams.Clone()
        $IntuneAppParamsForLogging.Remove('Icon')

        Log-Params -Params $IntuneAppParamsForLogging

        Write-EnhancedLog -Message "Calling Add-IntuneWin32App with IntuneAppParams - in progress" -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
        $Win32App = Add-IntuneWin32App @IntuneAppParams
        Write-EnhancedLog -Message "Win32 app added successfully. App ID: $($Win32App.id)" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)

        Write-EnhancedLog -Message "Assigning Win32 app to all users..." -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
        Add-IntuneWin32AppAssignmentAllUsers -ID $Win32App.id -Intent "available" -Notification "showAll" -Verbose
        Write-EnhancedLog -Message "Assignment completed successfully." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
    }
    catch {
        Write-EnhancedLog -Message "Error during IntuneWin32 app process: $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
        Write-Host "Error during IntuneWin32 app process: $_" -ForegroundColor Red
        exit
    }
}

function Create-DetectionRule {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prg_Path
    )

    Write-EnhancedLog -Message "Creating detection rule..." -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
    $detectionScriptPath = Join-Path -Path $Prg_Path -ChildPath "check.ps1"
    if (-not (Test-Path -Path $detectionScriptPath)) {
        Write-Warning "Detection rule script file does not exist at path: $detectionScriptPath"
    }
    else {
        $DetectionRule = New-IntuneWin32AppDetectionRuleScript -ScriptFile $detectionScriptPath -EnforceSignatureCheck $false -RunAs32Bit $false
    }
    Write-EnhancedLog -Message "Detection rule set (calling New-IntuneWin32AppDetectionRuleScript) - done" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)

    return $DetectionRule
}

function Create-RequirementRule {
    Write-EnhancedLog -Message "Setting minimum requirements..." -Level "WARNING" -ForegroundColor ([ConsoleColor]::Yellow)
    $RequirementRule = New-IntuneWin32AppRequirementRule -Architecture "x64" -MinimumSupportedWindowsRelease "W10_1607"
    Write-EnhancedLog -Message "Minimum requirements set - done" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)

    return $RequirementRule
}

function Set-AppIcon {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prg_img
    )

    $Icon = New-IntuneWin32AppIcon -FilePath $Prg_img
    Write-EnhancedLog -Message "App icon set - done" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)

    return $Icon
}
