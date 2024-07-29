function Remove-IntuneWinFiles {


    <#
.SYNOPSIS
    Removes all *.intuneWin files from a specified directory.

.DESCRIPTION
    This function searches for all files with the .intuneWin extension
    in the specified directory and removes them. It logs actions taken
    and any errors encountered using the Write-EnhancedLog function.

.PARAMETER DirectoryPath
    The path to the directory from which *.intuneWin files will be removed.

.EXAMPLE
    Remove-IntuneWinFiles -DirectoryPath "d:\Users\aollivierre\AppData\Local\Intune-Win32-Deployer\apps-winget"
    Removes all *.intuneWin files from the specified directory and logs the actions.

.NOTES
    Ensure you have the necessary permissions to delete files in the specified directory.

#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DirectoryPath
    )

    process {
        Write-EnhancedLog -Message "Starting to remove *.intuneWin files from $DirectoryPath recursively." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)

        try {
            # Include -Recurse to search within all subdirectories
            $files = Get-ChildItem -Path $DirectoryPath -Filter "*.intuneWin" -Recurse -ErrorAction Stop

            if ($files.Count -eq 0) {
                Write-EnhancedLog -Message "No *.intuneWin files found in $DirectoryPath." -Level "INFO" -ForegroundColor ([ConsoleColor]::Yellow)
            }
            else {
                foreach ($file in $files) {
                    Remove-Item $file.FullName -Force -ErrorAction Stop
                    Write-EnhancedLog -Message "Removed file: $($file.FullName)" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
                }
            }
        }
        catch {
            Write-EnhancedLog -Message "Error removing *.intuneWin files: $_" -Level "ERROR" -ForegroundColor ([ConsoleColor]::Red)
            throw $_  # Optionally re-throw the error to handle it further up the call stack.
        }

        Write-EnhancedLog -Message "Completed removal of *.intuneWin files from $DirectoryPath recursively." -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
    }
}