function CreateVMFolder {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$VMPath,
        
        [Parameter(Mandatory = $true)]
        [string]$VMName
    )

    Begin {
        Write-EnhancedLog -Message "Starting CreateVMFolder function" -Level "INFO"
        Log-Params -Params @{ VMPath = $VMPath; VMName = $VMName }
    }

    Process {
        try {
            $VMFullPath = Join-Path -Path $VMPath -ChildPath $VMName
            Write-EnhancedLog -Message "Creating VM folder at path: $VMFullPath" -Level "INFO"
            New-Item -ItemType Directory -Force -Path $VMFullPath | Out-Null
            Write-EnhancedLog -Message "VM folder created at $VMFullPath" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
            return $VMFullPath
        } catch {
            Write-EnhancedLog -Message "An error occurred while creating the VM folder: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Create-VMFolder function" -Level "INFO"
    }
}
