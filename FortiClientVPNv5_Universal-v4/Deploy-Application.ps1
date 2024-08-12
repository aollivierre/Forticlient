<#
.SYNOPSIS

PSApppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION

- The script is provided as a template to perform an install or uninstall of an application(s).
- The script either performs an "Install" deployment type or an "Uninstall" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.

PSApppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2024 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham and Muhammad Mashwani).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.PARAMETER DeploymentType

The type of deployment to perform. Default is: Install.

.PARAMETER DeployMode

Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.

.PARAMETER AllowRebootPassThru

Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

.PARAMETER TerminalServerMode

Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

.PARAMETER DisableLogging

Disables logging to file for the script. Default is: $false.

.EXAMPLE

powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"

.EXAMPLE

powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"

.EXAMPLE

powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"

.EXAMPLE

Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"

.INPUTS

None

You cannot pipe objects to this script.

.OUTPUTS

None

This script does not generate any output.

.NOTES

Toolkit Exit Code Ranges:
- 60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
- 69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
- 70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1

.LINK

https://psappdeploytoolkit.com
#>


[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [String]$DeploymentType = 'Install',
    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [String]$DeployMode = 'Interactive',
    [Parameter(Mandatory = $false)]
    [switch]$AllowRebootPassThru = $false,
    [Parameter(Mandatory = $false)]
    [switch]$TerminalServerMode = $false,
    [Parameter(Mandatory = $false)]
    [switch]$DisableLogging = $false
)

Try {
    ## Set the script execution policy for this process
    Try {
        Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop'
    }
    Catch {
    }

    ##*===============================================
    ##* VARIABLE DECLARATION
    ##*===============================================
    ## Variables: Application
    [String]$appVendor = 'Fortinet'
    [String]$appName = 'FortiClient VPN'
    [String]$appVersion = '7.4.0.1658'
    [String]$appArch = ''
    [String]$appLang = 'EN'
    [String]$appRevision = '01'
    [String]$appScriptVersion = '1.0.0'
    [String]$appScriptDate = '22/07/2024'
    [String]$appScriptAuthor = 'AOllivierre'
    ##*===============================================
    ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
    [String]$installName = ''
    [String]$installTitle = ''

    ##* Do not modify section below
    #region DoNotModify

    ## Variables: Exit Code
    [Int32]$mainExitCode = 0

    ## Variables: Script
    [String]$deployAppScriptFriendlyName = 'Deploy Application'
    [Version]$deployAppScriptVersion = [Version]'3.10.1'
    [String]$deployAppScriptDate = '05/03/2024'
    [Hashtable]$deployAppScriptParameters = $PsBoundParameters

    ## Variables: Environment
    If (Test-Path -LiteralPath 'variable:HostInvocation') {
        $InvocationInfo = $HostInvocation
    }
    Else {
        $InvocationInfo = $MyInvocation
    }

    ## Dot source the required App Deploy Toolkit Functions
    Try {
        [String]$moduleAppDeployToolkitMain = "$PSScriptroot\AppDeployToolkit\AppDeployToolkitMain.ps1"
        If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) {
            Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]."
        }
        If ($DisableLogging) {
            . $moduleAppDeployToolkitMain -DisableLogging
        }
        Else {
            . $moduleAppDeployToolkitMain
        }
    }
    Catch {
        If ($mainExitCode -eq 0) {
            [Int32]$mainExitCode = 60008
        }
        Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
        ## Exit the script, returning the exit code to SCCM
        If (Test-Path -LiteralPath 'variable:HostInvocation') {
            $script:ExitCode = $mainExitCode; Exit
        }
        Else {
            Exit $mainExitCode
        }
    }

    #endregion
    ##* Do not modify section above
    ##*===============================================
    ##* END VARIABLE DECLARATION
    ##*===============================================


    # Read configuration from the JSON file
    # Assign values from JSON to variables

    # Read configuration from the JSON file
    $configPath = Join-Path -Path $PSScriptRoot -ChildPath "config.json"
    $env:MYMODULE_CONFIG_PATH = $configPath

    $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

    function Initialize-Environment {
        param (
            [string]$WindowsModulePath = "EnhancedBoilerPlateAO\2.0.0\EnhancedBoilerPlateAO.psm1",
            [string]$LinuxModulePath = "/usr/src/code/Modules/EnhancedBoilerPlateAO/2.0.0/EnhancedBoilerPlateAO.psm1"
        )

        function Get-Platform {
            if ($PSVersionTable.PSVersion.Major -ge 7) {
                return $PSVersionTable.Platform
            }
            else {
                return [System.Environment]::OSVersion.Platform
            }
        }

        function Setup-GlobalPaths {
            if ($env:DOCKER_ENV -eq $true) {
                $global:scriptBasePath = $env:SCRIPT_BASE_PATH
                $global:modulesBasePath = $env:MODULES_BASE_PATH
            }
            else {
                $global:scriptBasePath = $PSScriptRoot
                $global:modulesBasePath = "C:\code\modules"
                if (-Not (Test-Path $global:modulesBasePath)) {
                    $global:modulesBasePath = "$PSScriptRoot\modules"
                }
                if (-Not (Test-Path $global:modulesBasePath)) {
                    $global:modulesBasePath = "$PSScriptRoot\modules"
                    Download-Modules -destinationPath $global:modulesBasePath
                }
            }
        }

        function Download-Modules {
            param (
                [string]$repoUrl = "https://github.com/aollivierre/modules/archive/refs/heads/main.zip",
                [string]$destinationPath
            )

            $timestamp = Get-Date -Format "yyyyMMddHHmmss"
            $tempExtractPath = "$env:TEMP\modules-$timestamp"
            $zipPath = "$env:TEMP\modules.zip"

            Write-Host "Downloading modules from GitHub..."
            Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath
            Expand-Archive -Path $zipPath -DestinationPath $tempExtractPath -Force
            Remove-Item -Path $zipPath

            $extractedFolder = Join-Path -Path $tempExtractPath -ChildPath "modules-main"
            if (Test-Path $extractedFolder) {
                Write-Host "Copying extracted modules to $destinationPath"
                robocopy $extractedFolder $destinationPath /E
                Remove-Item -Path $tempExtractPath -Recurse -Force
            }

            # $DBG

            Write-Host "Modules downloaded and extracted to $destinationPath"
        }

        function Setup-WindowsEnvironment {
            # Get the base paths from the global variables
            Setup-GlobalPaths

            # Construct the paths dynamically using the base paths
            $modulePath = Join-Path -Path $global:modulesBasePath -ChildPath $WindowsModulePath

            $global:modulePath = $modulePath
            $global:AOscriptDirectory = Join-Path -Path $scriptBasePath -ChildPath "Win32Apps-DropBox"
            $global:directoryPath = Join-Path -Path $scriptBasePath -ChildPath "Win32Apps-DropBox"
            $global:Repo_Path = $scriptBasePath
            $global:Repo_winget = "$Repo_Path\Win32Apps-DropBox"

            # Import the module using the dynamically constructed path
            Import-Module -Name $global:modulePath -Verbose -Force:$true -Global:$true

            # Log the paths to verify
            Write-Output "Module Path: $global:modulePath"
            Write-Output "Repo Path: $global:Repo_Path"
            Write-Output "Repo Winget Path: $global:Repo_winget"
        }

        function Setup-LinuxEnvironment {
            # Get the base paths from the global variables
            Setup-GlobalPaths

            # Import the module using the Linux path
            Import-Module $LinuxModulePath -Verbose

            # Convert paths from Windows to Linux format
            $global:AOscriptDirectory = Convert-WindowsPathToLinuxPath -WindowsPath "$PSscriptroot"
            $global:directoryPath = Convert-WindowsPathToLinuxPath -WindowsPath "$PSscriptroot\Win32Apps-DropBox"
            $global:Repo_Path = Convert-WindowsPathToLinuxPath -WindowsPath "$PSscriptroot"
            $global:Repo_winget = "$global:Repo_Path\Win32Apps-DropBox"
        }

        $platform = Get-Platform
        if ($platform -eq 'Win32NT' -or $platform -eq [System.PlatformID]::Win32NT) {
            Setup-WindowsEnvironment
        }
        elseif ($platform -eq 'Unix' -or $platform -eq [System.PlatformID]::Unix) {
            Setup-LinuxEnvironment
        }
        else {
            throw "Unsupported operating system"
        }
    }

    # Call the function to initialize the environment
    Initialize-Environment



    # Example usage of global variables outside the function
    Write-Output "Global variables set by Initialize-Environment:"
    Write-Output "scriptBasePath: $scriptBasePath"
    Write-Output "modulesBasePath: $modulesBasePath"
    Write-Output "modulePath: $modulePath"
    Write-Output "AOscriptDirectory: $AOscriptDirectory"
    Write-Output "directoryPath: $directoryPath"
    Write-Output "Repo_Path: $Repo_Path"
    Write-Output "Repo_winget: $Repo_winget"

    #################################################################################################################################
    ################################################# END VARIABLES #################################################################
    #################################################################################################################################

    ###############################################################################################################################
    ############################################### START MODULE LOADING ##########################################################
    ###############################################################################################################################

    <#
.SYNOPSIS
Dot-sources all PowerShell scripts in the 'private' folder relative to the script root.

.DESCRIPTION
This function finds all PowerShell (.ps1) scripts in a 'private' folder located in the script root directory and dot-sources them. It logs the process, including any errors encountered, with optional color coding.

.EXAMPLE
Dot-SourcePrivateScripts

Dot-sources all scripts in the 'private' folder and logs the process.

.NOTES
Ensure the Write-EnhancedLog function is defined before using this function for logging purposes.
#>


    try {

        # Check if C:\code\modules exists
        if (Test-Path "C:\code\modules") {
            $ModulesFolderPath = Get-ModulesFolderPath -WindowsPath "C:\code\modules" -UnixPath "/usr/src/code/modules"
        }
        else {
            $ModulesFolderPath = Get-ModulesFolderPath -WindowsPath "$PsScriptRoot\modules" -UnixPath "$PsScriptRoot/modules"
        }

        Write-Host "Modules Folder Path: $ModulesFolderPath"

    }
    catch {
        Write-Error $_.Exception.Message
    }


    Write-Host "Starting to call Import-LatestModulesLocalRepository..."
    Import-LatestModulesLocalRepository -ModulesFolderPath $ModulesFolderPath -ScriptPath $PSScriptRoot

    ###############################################################################################################################
    ############################################### END MODULE LOADING ############################################################
    ###############################################################################################################################
    try {
        # Ensure-LoggingFunctionExists -LoggingFunctionName "# Write-EnhancedLog"
        # Continue with the rest of the script here
        # exit
    }
    catch {
        Write-Host "Critical error: $_" -ForegroundColor Red
        exit
    }

    ###############################################################################################################################
    ###############################################################################################################################
    ###############################################################################################################################

    # Setup logging
    Write-EnhancedLog -Message "Script Started" -Level "INFO"

    ################################################################################################################################
    ################################################################################################################################
    ################################################################################################################################


    # ################################################################################################################################
    # ############### CALLING AS SYSTEM to simulate Intune deployment as SYSTEM (Uncomment for debugging) ############################
    # ################################################################################################################################

    # Example usage
    $privateFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "private"
    $PsExec64Path = Join-Path -Path $privateFolderPath -ChildPath "PsExec64.exe"
    $ScriptToRunAsSystem = $MyInvocation.MyCommand.Path

    Ensure-RunningAsSystem -PsExec64Path $PsExec64Path -ScriptPath $ScriptToRunAsSystem -TargetFolder $privateFolderPath


    # ################################################################################################################################
    # ############### END CALLING AS SYSTEM to simulate Intune deployment as SYSTEM (Uncomment for debugging) ########################
    # ################################################################################################################################



    If ($deploymentType -ine 'Uninstall' -and $deploymentType -ine 'Repair') {
        ##*===============================================
        ##* PRE-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Installation'

        ## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
        # Show-InstallationWelcome -CloseApps 'iexplore' -AllowDefer -DeferTimes 3 -CheckDiskSpace -PersistPrompt
        Show-InstallationWelcome -CloseApps 'iexplore' -CheckDiskSpace -PersistPrompt

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Installation tasks here>


        ##*===============================================
        ##* INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Installation'

        ## Handle Zero-Config MSI Installations
        If ($useDefaultMsi) {
            [Hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) {
                $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile)
            }
            Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) {
                $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ }
            }
        }

        ## <Perform Installation tasks here>


        # Start-Process -FilePath 'MsiExec.exe' -ArgumentList "/i `"$PSScriptroot\FortiClient.msi`" /quiet /norestart" -Wait


        # Example usage of Install-MsiPackage function with splatting
        $params = @{
            ScriptRoot       = $PSScriptRoot
            MsiFileName      = 'FortiClient.msi'
            FilePath         = 'MsiExec.exe'
            ArgumentTemplate = "/i `{InstallerPath}` /quiet /norestart"
        }
        Install-MsiPackage @params




        # Define constants for registry paths and minimum required version
        $registryPaths = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
            'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
        )
        $targetSoftwareName = '*FortiClient*'
        $minimumVersion = New-Object Version '7.4.0.1658'        

        # Main script execution block
        $installationCheck = WaitForRegistryKey -RegistryPaths $registryPaths -SoftwareName $targetSoftwareName -MinimumVersion $minimumVersion -TimeoutSeconds 120

        if ($installationCheck.IsInstalled) {
            # Write-Output "FortiClientVPN version $($installationCheck.Version) or later is installed."
            # exit 0
        }
        else {
            # Write-Output "FortiClientVPN version $minimumVersion or later is not installed."
            # exit 1
        }






        # Start-Process -FilePath 'reg.exe' -ArgumentList "import `"$PSScriptroot\CBA_National_SSL_VPN_SAML.reg`"" -Wait


        
        # Example usage of Import-RegistryFilesInScriptRoot function
        # Call the function to import all registry files in the script roo

        $ImportRegistryFilesInScriptRootparams = @{
            Filter          = "*.reg"
            FilePath        = "reg.exe"
            Arguments       = "import `"$registryFilePath`""
            ScriptDirectory = $PSScriptRoot
        }

        # Call the Import-RegistryFilesInScriptRoot function using splatting
        Import-RegistryFilesInScriptRoot @ImportRegistryFilesInScriptRootparams



        # Example usage of Import-FortiClientConfig function with splatting
        $ImportFortiClientConfigParams = @{
            ScriptRoot          = $PSScriptRoot
            FortiClientPath     = "C:\Program Files\Fortinet\FortiClient"
            ConfigFileExtension = "*.xml"
            FCConfigExecutable  = "FCConfig.exe"
            ArgumentTemplate    = "-m all -f `{ConfigFilePath}` -o import -i 1"
        }
        
        # Call the Import-FortiClientConfig function using splatting
        Import-FortiClientConfig @ImportFortiClientConfigParams
        

        
      

        ##*===============================================
        ##* POST-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Installation'

        ## <Perform Post-Installation tasks here>

        ## Display a message at the end of the install
        If (-not $useDefaultMsi) {

            Show-InstallationProgress -Status 'Unscheduling the post reboot installer'


            # Define the function to get the appropriate PowerShell path
            function Get-PowerShellPath {
                if (Test-Path "C:\Program Files\PowerShell\7\pwsh.exe") {
                    return "C:\Program Files\PowerShell\7\pwsh.exe"
                }
                elseif (Test-Path "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe") {
                    return "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
                }
                else {
                    throw "Neither PowerShell 7 nor PowerShell 5 was found on this system."
                }
            }

            # Get the PowerShell path using the function
            $powerShellPath = Get-PowerShellPath

            # Define the path to the unscheduler.ps1 script
            $scriptPath = "$PSScriptRoot\unscheduler.ps1"

            # Define the arguments for the script using splatting
            $startProcessParams = @{
                FilePath     = $powerShellPath
                ArgumentList = @("-NoExit", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$scriptPath`"")
                Wait         = $true
            }

            # Start the process
            Start-Process @startProcessParams







            Show-InstallationPrompt -Message 'You should now see FortiClient VPN v7.4.0.1658 in your task bar' -ButtonRightText 'OK' -Icon Information -NoWait
        }
    }
    ElseIf ($deploymentType -ieq 'Uninstall') {
        ##*===============================================
        ##* PRE-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Uninstallation'

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
        Show-InstallationWelcome -CloseApps 'iexplore' -CloseAppsCountdown 60

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Uninstallation tasks here>


        ##*===============================================
        ##* UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Uninstallation'

        ## Handle Zero-Config MSI Uninstallations
        If ($useDefaultMsi) {
            [Hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) {
                $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile)
            }
            Execute-MSI @ExecuteDefaultMSISplat
        }

        ## <Perform Uninstallation tasks here>


        # Show the prompt to the user to click "Continue"
        $promptParams = @{
            Message        = 'Click "Continue" to proceed with the uninstallation. The system will reboot after the uninstallation.'
            ButtonLeftText = 'Continue'
            Icon           = 'Warning'
            TopMost        = $true
        }

        $promptResult = Show-InstallationPrompt @promptParams

        # Check the user's response
        If ($promptResult -eq 'Continue') {
            # Show progress for the uninstallation
            Show-InstallationProgress -Status 'Uninstalling Your Application...'
    
            try {
                # Call your uninstall commands here
       
                # Example usage of Uninstall-FortiClientEMSAgentApplication function with splatting
                $UninstallFortiClientEMSAgentApplicationParams = @{
                    UninstallKeys    = @(
                        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
                        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
                    )
                    ApplicationName  = '*Forti*'
                    FilePath         = 'MsiExec.exe'
                    ArgumentTemplate = "/X{ProductId} /quiet /norestart"
                }
                Uninstall-FortiClientEMSAgentApplication @UninstallFortiClientEMSAgentApplicationParams


                # Show restart prompt after uninstallation
                # Show-InstallationRestartPrompt -CountdownSeconds 60 -CountdownNoHideSeconds 60 -TopMost $true
            }
            catch {
                # Write-Log -Message "An error occurred during the uninstallation process: $_" -Severity 3
                # Exit-Script -ExitCode 1
            }
        }
        else {
            # Write-Log -Message "Unexpected response or prompt timeout." -Severity 3
            # Exit-Script -ExitCode 1
        }

        # If script execution reaches this point, exit with success code
        # Exit-Script -ExitCode 0

    
        ##*===============================================
        ##* POST-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Uninstallation'

        ## <Perform Post-Uninstallation tasks here>


    }
    ElseIf ($deploymentType -ieq 'Repair') {
        ##*===============================================
        ##* PRE-REPAIR
        ##*===============================================
        [String]$installPhase = 'Pre-Repair'

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
        Show-InstallationWelcome -CloseApps 'iexplore' -CloseAppsCountdown 60

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Repair tasks here>

        ##*===============================================
        ##* REPAIR
        ##*===============================================
        [String]$installPhase = 'Repair'

        ## Handle Zero-Config MSI Repairs
        If ($useDefaultMsi) {
            [Hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Repair'; Path = $defaultMsiFile; }; If ($defaultMstFile) {
                $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile)
            }
            Execute-MSI @ExecuteDefaultMSISplat
        }
        ## <Perform Repair tasks here>

        ##*===============================================
        ##* POST-REPAIR
        ##*===============================================
        [String]$installPhase = 'Post-Repair'

        ## <Perform Post-Repair tasks here>


    }
    ##*===============================================
    ##* END SCRIPT BODY
    ##*===============================================

    ## Call the Exit-Script function to perform final cleanup operations
    Exit-Script -ExitCode $mainExitCode
}
Catch {
    [Int32]$mainExitCode = 60001
    [String]$mainErrorMessage = "$(Resolve-Error)"
    Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
    Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
    Exit-Script -ExitCode $mainExitCode
}
