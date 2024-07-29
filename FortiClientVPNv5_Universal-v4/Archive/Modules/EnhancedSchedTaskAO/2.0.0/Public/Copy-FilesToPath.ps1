function Copy-FilesToPath {
    <#
.SYNOPSIS
Copies all files and folders in the specified source directory to the specified destination path.

.DESCRIPTION
This function copies all files and folders located in the specified source directory to the specified destination path. It can be used to bundle necessary files and folders with the script for distribution or deployment.

.PARAMETER SourcePath
The source path from where the files and folders will be copied.

.PARAMETER DestinationPath
The destination path where the files and folders will be copied.

.EXAMPLE
Copy-FilesToPath -SourcePath "C:\Source" -DestinationPath "C:\Temp"

This example copies all files and folders in the "C:\Source" directory to the "C:\Temp" directory.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting the copy process from the Source Path $SourcePath to $DestinationPath" -Level "INFO"
        Log-Params -Params @{
            SourcePath = $SourcePath
            DestinationPath = $DestinationPath
        }

        # Ensure the destination directory exists
        if (-not (Test-Path -Path $DestinationPath)) {
            New-Item -Path $DestinationPath -ItemType Directory | Out-Null
        }
    }

    Process {
        try {
            # Copy all items from the source directory to the destination, including subdirectories
            $copyParams = @{
                Path        = "$SourcePath\*"
                Destination = $DestinationPath
                Recurse     = $true
                Force       = $true
                ErrorAction = "Stop"
            }
            Copy-Item @copyParams

            Write-EnhancedLog -Message "All items copied successfully from the Source Path $SourcePath to $DestinationPath." -Level "INFO"
        } catch {
            Write-EnhancedLog -Message "Error occurred during the copy process: $_" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Copy process completed." -Level "INFO"
    }
}



# # Define parameters for the function
# $sourcePath = "C:\SourceDirectory"
# $destinationPath = "C:\DestinationDirectory"

# # Call the function with the defined parameters
# Copy-FilesToPath -SourcePath $sourcePath -DestinationPath $destinationPath
