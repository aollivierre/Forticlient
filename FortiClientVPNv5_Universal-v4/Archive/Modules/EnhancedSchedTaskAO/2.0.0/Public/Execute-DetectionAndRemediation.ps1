
function Execute-DetectionAndRemediation {

    <#
.SYNOPSIS
Executes detection and remediation scripts located in a specified directory.

.DESCRIPTION
This function navigates to the specified directory and executes the detection script. If the detection script exits with a non-zero exit code, indicating a positive detection, the remediation script is then executed. The function uses enhanced logging for status messages and error handling to manage any issues that arise during execution.

.PARAMETER Path_PR
The path to the directory containing the detection and remediation scripts.

.EXAMPLE
Execute-DetectionAndRemediation -Path_PR "C:\Scripts\MyTask"
This example executes the detection and remediation scripts located in "C:\Scripts\MyTask".
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        # [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]$Path_PR
    )

    try {
        Write-EnhancedLog -Message "Executing detection and remediation scripts in $Path_PR..." -Level "INFO" -ForegroundColor Magenta
        Set-Location -Path $Path_PR

        # Execution of the detection script
        & .\detection.ps1
        if ($LASTEXITCODE -ne 0) {
            Write-EnhancedLog -Message "Detection positive, remediation starts now." -Level "INFO" -ForegroundColor Green
            & .\remediation.ps1
        }
        else {
            Write-EnhancedLog -Message "Detection negative, no further action needed." -Level "INFO" -ForegroundColor Yellow
        }
    }
    catch {
        Write-EnhancedLog -Message "An error occurred during detection and remediation execution: $_" -Level "ERROR" -ForegroundColor Red
        throw $_
    }
}

