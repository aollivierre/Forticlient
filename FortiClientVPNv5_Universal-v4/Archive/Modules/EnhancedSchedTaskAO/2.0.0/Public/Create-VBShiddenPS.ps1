

function Create-VBShiddenPS {

    <#
.SYNOPSIS
Creates a VBScript file to run a PowerShell script hidden from the user interface.

.DESCRIPTION
This function generates a VBScript (.vbs) file designed to execute a PowerShell script without displaying the PowerShell window. It's particularly useful for running background tasks or scripts that do not require user interaction. The path to the PowerShell script is taken as an argument, and the VBScript is created in a specified directory within the global path variable.

.EXAMPLE
$Path_VBShiddenPS = Create-VBShiddenPS

This example creates the VBScript file and returns its path.
#>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path_local,

        [string]$DataFolder = "Data",

        [string]$FileName = "run-ps-hidden.vbs"
    )

    try {
        # Construct the full path for DataFolder and validate it manually
        $fullDataFolderPath = Join-Path -Path $Path_local -ChildPath $DataFolder
        if (-not (Test-Path -Path $fullDataFolderPath -PathType Container)) {
            throw "DataFolder does not exist or is not a directory: $fullDataFolderPath"
        }

        # Log message about creating VBScript
        Write-EnhancedLog -Message "Creating VBScript to hide PowerShell window..." -Level "INFO" -ForegroundColor Magenta

        $scriptBlock = @"
Dim shell,fso,file

Set shell=CreateObject("WScript.Shell")
Set fso=CreateObject("Scripting.FileSystemObject")

strPath=WScript.Arguments.Item(0)

If fso.FileExists(strPath) Then
    set file=fso.GetFile(strPath)
    strCMD="powershell -nologo -executionpolicy ByPass -command " & Chr(34) & "&{" & file.ShortPath & "}" & Chr(34)
    shell.Run strCMD,0
End If
"@

        # Combine paths to construct the full path for the VBScript
        $folderPath = $fullDataFolderPath
        $Path_VBShiddenPS = Join-Path -Path $folderPath -ChildPath $FileName

        # Write the script block to the VBScript file
        $scriptBlock | Out-File -FilePath (New-Item -Path $Path_VBShiddenPS -Force) -Force

        # Validate the VBScript file creation
        if (Test-Path -Path $Path_VBShiddenPS) {
            Write-EnhancedLog -Message "VBScript created successfully at $Path_VBShiddenPS" -Level "INFO" -ForegroundColor Green
        }
        else {
            throw "Failed to create VBScript at $Path_VBShiddenPS"
        }

        return $Path_VBShiddenPS
    }
    catch {
        Write-EnhancedLog -Message "An error occurred while creating VBScript: $_" -Level "ERROR" -ForegroundColor Red
        throw $_
    }
}