function Add-GuidToPs1Files {


    <#
.SYNOPSIS
Adds a unique GUID and timestamp to the top of each .ps1 file in a specified directory.

.DESCRIPTION
This function searches for PowerShell script files (.ps1) within a specified subdirectory of a given root directory. It then prepends a unique GUID and a timestamp to each file for tracking purposes. This is useful for marking scripts in bulk operations or deployments.

.PARAMETER AOscriptDirectory
The root directory under which the target program folder resides.

.PARAMETER programfoldername
The name of the subdirectory containing the .ps1 files to be modified.

.EXAMPLE
Add-GuidToPs1Files -AOscriptDirectory "d:\Scripts" -programfoldername "MyProgram"

Adds a tracking GUID and timestamp to all .ps1 files under "d:\Scripts\apps-winget\MyProgram".

.NOTES
Author: Your Name
Date: Get the current date
Version: 1.0

#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        # [ValidateScript({Test-Path $_})]
        [string]$AOscriptDirectory,

        [Parameter(Mandatory = $true)]
        [string]$programfoldername
    )

    # Helper function for logging
    Begin {
        Write-EnhancedLog -Message "Starting to modify PowerShell files." -Level "INFO" -ForegroundColor Green
    }

    Process {
        $targetFolder = Join-Path -Path $AOscriptDirectory -ChildPath "apps-winget\$programfoldername"

        if (-Not (Test-Path -Path $targetFolder)) {
            Write-EnhancedLog -Message "The target folder does not exist: $targetFolder" -Level "ERROR" -ForegroundColor Red
            return
        }

        $ps1Files = Get-ChildItem -Path $targetFolder -Filter *.ps1 -Recurse
        if ($ps1Files.Count -eq 0) {
            Write-EnhancedLog -Message "No PowerShell files (.ps1) found in $targetFolder" -Level "WARNING" -ForegroundColor Yellow
            return
        }

        foreach ($file in $ps1Files) {
            try {
                $content = Get-Content -Path $file.FullName -ErrorAction Stop
                $pattern = '^#Unique Tracking ID: .+'
                $content = $content | Where-Object { $_ -notmatch $pattern }

                $guid = [guid]::NewGuid().ToString("D").ToLower()
                $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
                $lineToAdd = "#Unique Tracking ID: $guid, Timestamp: $timestamp"
                $newContent = $lineToAdd, $content

                Set-Content -Path $file.FullName -Value $newContent -ErrorAction Stop
                Write-EnhancedLog -Message "Modified file: $($file.FullName)" -Level "VERBOSE" -ForegroundColor Yellow
            }
            catch {
                Write-EnhancedLog -Message "Failed to modify file: $($file.FullName). Error: $($_.Exception.Message)" -Level "ERROR" -ForegroundColor Red
            }
        }
    }

    End {
        Write-EnhancedLog -Message "Completed modifications." -Level "INFO" -ForegroundColor Cyan
    }
}


# Example usage:
# Add-GuidToPs1Files -AOscriptDirectory $AOscriptDirectory