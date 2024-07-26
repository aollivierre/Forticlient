function Download-InstallServiceUI {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        # [string]$TargetFolder = "$PSScriptRoot\private",
        [string]$TargetFolder,

        [Parameter(Mandatory = $true)]
        [string]$URL
    )

    Begin {
        Write-EnhancedLog -Message "Starting Download-InstallServiceUI function" -Level "INFO"
        Log-Params -Params @{
            TargetFolder = $TargetFolder
            URL = $URL
        }

        try {
            Remove-ExistingServiceUI -TargetFolder $TargetFolder
        } catch {
            Write-EnhancedLog -Message "Error during Remove-ExistingServiceUI: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    Process {
        # Path for the downloaded MSI file
        $msiPath = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath "MicrosoftDeploymentToolkit_x64.msi"
        $logPath = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath "MDT_Install.log"
        
        try {
            # Download the MDT MSI file
            Write-EnhancedLog -Message "Downloading MDT MSI from: $URL to: $msiPath" -Level "INFO"
            Invoke-WebRequest -Uri $URL -OutFile $msiPath

            # Install the MSI silently with logging
            Write-EnhancedLog -Message "Installing MDT MSI from: $msiPath" -Level "INFO"
            CheckAndElevate
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /quiet /norestart /l*v `"$logPath`"" -Wait

            # Path to the installed ServiceUI.exe
            $installedServiceUIPath = "C:\Program Files\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x64\ServiceUI.exe"
            $finalPath = Join-Path -Path $TargetFolder -ChildPath "ServiceUI.exe"

            # Ensure the destination directory exists
            if (-not (Test-Path -Path $TargetFolder)) {
                Write-EnhancedLog -Message "Creating target folder: $TargetFolder" -Level "INFO"
                New-Item -ItemType Directory -Path $TargetFolder -Force
            }

            # Move ServiceUI.exe to the desired location
            if (Test-Path -Path $installedServiceUIPath) {
                Write-EnhancedLog -Message "Copying ServiceUI.exe from: $installedServiceUIPath to: $finalPath" -Level "INFO"
                Copy-Item -Path $installedServiceUIPath -Destination $finalPath -Force

                if (Test-Path -Path $finalPath) {
                    Write-EnhancedLog -Message "ServiceUI.exe has been successfully copied to: $finalPath" -Level "INFO"
                } else {
                    throw "ServiceUI.exe not successfully copied to: $finalPath"
                }
            } else {
                throw "ServiceUI.exe not found at: $installedServiceUIPath"
            }

            # Remove the downloaded MSI file
            Remove-Item -Path $msiPath -Force
        } catch {
            Write-EnhancedLog -Message "An error occurred: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Download-InstallServiceUI function" -Level "INFO"
    }
}

# Example usage
# Download-InstallServiceUI -TargetFolder 'C:\YourPath\private' -URL 'https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi'
