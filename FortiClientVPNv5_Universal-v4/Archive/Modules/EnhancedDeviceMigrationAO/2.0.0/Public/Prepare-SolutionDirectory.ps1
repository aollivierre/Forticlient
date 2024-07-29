function Prepare-SolutionDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ToolkitFolder,

        [Parameter(Mandatory = $true)]
        [string]$FilesFolder
    )

    Begin {
        Write-EnhancedLog -Message "Starting Prepare-SolutionDirectory function" -Level "INFO"
        Log-Params -Params @{
            ToolkitFolder = $ToolkitFolder
            FilesFolder = $FilesFolder
        }
    }

    Process {
        try {
            # Create necessary directories
            New-Item -ItemType Directory -Path $ToolkitFolder -Force
            New-Item -ItemType Directory -Path $FilesFolder -Force
        } catch {
            Write-EnhancedLog -Message "An error occurred while processing the Prepare-SolutionDirectory function: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Prepare-SolutionDirectory function" -Level "INFO"
    }
}

# Example usage
# Prepare-SolutionDirectory -ToolkitFolder "C:\path\to\toolkit" -FilesFolder "C:\path\to\files"
