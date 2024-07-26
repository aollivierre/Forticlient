function Start-ServiceUIWithAppDeploy {
    [CmdletBinding()]
    param (
        [string]$PSADTExecutable = "$PSScriptRoot\Private\PSAppDeployToolkit\Toolkit\Deploy-Application.exe",
        [string]$ServiceUIExecutable = "$PSScriptRoot\Private\ServiceUI.exe",
        [string]$DeploymentType = "Install",
        [string]$DeployMode = "Interactive"
    )

    try {
        # Verify if the ServiceUI executable exists
        if (-not (Test-Path -Path $ServiceUIExecutable)) {
            throw "ServiceUI executable not found at path: $ServiceUIExecutable"
        }

        # Verify if the PSAppDeployToolkit executable exists
        if (-not (Test-Path -Path $PSADTExecutable)) {
            throw "PSAppDeployToolkit executable not found at path: $PSADTExecutable"
        }

        # Log the start of the process
        Write-EnhancedLog -Message "Starting ServiceUI.exe with Deploy-Application.exe" -Level "INFO"

        # Define the arguments to pass to ServiceUI.exe
        $arguments = "-process:explorer.exe `"$PSADTExecutable`" -DeploymentType $DeploymentType -Deploymode $Deploymode"

        # Start the ServiceUI.exe process with the specified arguments
        Start-Process -FilePath $ServiceUIExecutable -ArgumentList $arguments -Wait -WindowStyle Hidden

        # Log successful completion
        Write-EnhancedLog -Message "ServiceUI.exe started successfully with Deploy-Application.exe" -Level "INFO"
    }
    catch {
        # Handle any errors during the process
        Write-Error "An error occurred: $_"
        Write-EnhancedLog -Message "An error occurred: $_" -Level "ERROR"
    }
}