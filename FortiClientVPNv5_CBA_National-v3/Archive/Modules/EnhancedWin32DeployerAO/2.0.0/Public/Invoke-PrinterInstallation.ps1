function Invoke-PrinterInstallation {

    <#
.SYNOPSIS
Installs or uninstalls printer drivers based on JSON configuration files.

.DESCRIPTION
This PowerShell function reads printer installation settings from a specified printer configuration JSON file (printer.json) and application configuration JSON file (config.json). It constructs and optionally executes command lines for installing or uninstalling printer drivers. The function proceeds only if the 'PrinterInstall' attribute in the application configuration is set to true.

.PARAMETER PrinterConfigPath
The full file path to the printer configuration JSON file (printer.json). This file contains the printer settings such as PrinterName, PrinterIPAddress, PortName, DriverName, InfPathRelative, InfFileName, and DriverIdentifier.

.PARAMETER AppConfigPath
The full file path to the application configuration JSON file (config.json). This file contains application-wide settings including the 'PrinterInstall' flag that controls whether the installation or uninstallation should proceed.

.EXAMPLE
.\Invoke-PrinterInstallation -PrinterConfigPath "d:\path\to\printer.json" -AppConfigPath "d:\path\to\config.json"

Executes the Invoke-PrinterInstallation function using the specified printer and application configuration files. It constructs and displays the install and uninstall commands based on the configurations.

.INPUTS
None. You cannot pipe objects to Invoke-PrinterInstallation.

.OUTPUTS
String. Outputs the constructed install and uninstall commands to the console.

.NOTES
Version:        1.0
Author:         Your Name
Creation Date:  The Date
Purpose/Change: Initial function development

.LINK
URL to more information if available

#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PrinterConfigPath, # Path to printer.json

        [Parameter(Mandatory = $true)]
        [string]$AppConfigPath  # Path to config.json
    )

    Begin {
        Write-EnhancedLog -Message "Starting Invoke-PrinterInstallation" -Level "INFO" -ForegroundColor Green
    }

    Process {
        try {
            if (-not (Test-Path -Path $PrinterConfigPath)) {
                Write-EnhancedLog -Message "Printer configuration file not found at path: $PrinterConfigPath" -Level "ERROR" -ForegroundColor Red
                throw "Printer configuration file not found."
            }

            if (-not (Test-Path -Path $AppConfigPath)) {
                Write-EnhancedLog -Message "Application configuration file not found at path: $AppConfigPath" -Level "ERROR" -ForegroundColor Red
                throw "Application configuration file not found."
            }

            $appConfig = Get-Content -Path $AppConfigPath -Raw | ConvertFrom-Json

            if ($appConfig.PrinterInstall -eq $true) {
                $printerConfig = Get-Content -Path $PrinterConfigPath -Raw | ConvertFrom-Json

                $InstallCommandLine = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -File ""install.ps1"""
                $UninstallCommandLine = "%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -executionpolicy bypass -File ""uninstall.ps1"""

                $printerConfig.psobject.Properties | ForEach-Object {
                    $InstallCommandLine += " -$($_.Name) `"$($_.Value)`""
                    $UninstallCommandLine += " -$($_.Name) `"$($_.Value)`""
                }

                Write-EnhancedLog -Message "Install and Uninstall command lines constructed successfully" -Level "VERBOSE" -ForegroundColor Cyan

                # Return a custom object containing both commands
                $commands = [PSCustomObject]@{
                    InstallCommand   = $InstallCommandLine
                    UninstallCommand = $UninstallCommandLine
                }

                return $commands

            }
            else {
                Write-EnhancedLog -Message "PrinterInstall is not set to true in the application configuration. No commands will be executed." -Level "WARNING" -ForegroundColor Yellow
            }

        }
        catch {
            Write-EnhancedLog -Message "An error occurred: $_" -Level "ERROR" -ForegroundColor Red
        }
    }

    End {
        Write-EnhancedLog -Message "Invoke-PrinterInstallation completed" -Level "INFO" -ForegroundColor Green
    }
}


# # Define paths to the configuration files
# $printerConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "printer.json"
# $appConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "config.json"

# Invoke-PrinterInstallation -PrinterConfigPath $printerConfigPath -AppConfigPath $appConfigPath