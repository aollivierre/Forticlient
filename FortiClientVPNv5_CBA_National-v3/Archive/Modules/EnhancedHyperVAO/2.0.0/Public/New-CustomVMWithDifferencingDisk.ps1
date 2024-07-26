function New-CustomVMWithDifferencingDisk {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$VMName,

        [Parameter(Mandatory = $true)]
        [string]$VMFullPath,

        [Parameter(Mandatory = $true)]
        [string]$ParentVHDPath,

        [Parameter(Mandatory = $true)]
        [string]$DifferencingDiskPath,

        [Parameter(Mandatory = $true)]
        [string]$SwitchName,

        [Parameter(Mandatory = $true)]
        [int64]$MemoryStartupBytes,

        [Parameter(Mandatory = $true)]
        [int64]$MemoryMinimumBytes,

        [Parameter(Mandatory = $true)]
        [int64]$MemoryMaximumBytes,

        [Parameter(Mandatory = $true)]
        [int]$Generation
    )

    Begin {
        Write-EnhancedLog -Message "Starting New-CustomVMWithDifferencingDisk function" -Level "INFO"
        Log-Params -Params @{
            VMName               = $VMName
            VMFullPath           = $VMFullPath
            ParentVHDPath        = $ParentVHDPath
            DifferencingDiskPath = $DifferencingDiskPath
            SwitchName           = $SwitchName
            MemoryStartupBytes   = $MemoryStartupBytes
            MemoryMinimumBytes   = $MemoryMinimumBytes
            MemoryMaximumBytes   = $MemoryMaximumBytes
            Generation           = $Generation
        }
    }

    Process {
        try {
            $NewVMSplat = @{
                Generation         = $Generation
                Path               = $VMFullPath
                Name               = $VMName
                MemoryStartupBytes = $MemoryStartupBytes
                SwitchName         = $SwitchName
                NoVHD              = $true
            }
            New-VM @NewVMSplat
            Write-EnhancedLog -Message "VM $VMName created with specified parameters" -Level "INFO"

            Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes $MemoryMinimumBytes -MaximumBytes $MemoryMaximumBytes -StartupBytes $MemoryStartupBytes
            Write-EnhancedLog -Message "Dynamic memory set for VM $VMName" -Level "INFO"

            New-VHD -Path $DifferencingDiskPath -ParentPath $ParentVHDPath -Differencing
            Write-EnhancedLog -Message "Differencing disk created at $DifferencingDiskPath based on $ParentVHDPath" -Level "INFO"

            Add-VMHardDiskDrive -VMName $VMName -Path $DifferencingDiskPath
            Write-EnhancedLog -Message "Differencing disk added to VM $VMName" -Level "INFO" -ForegroundColor ([ConsoleColor]::Green)
        } catch {
            Write-EnhancedLog -Message "An error occurred while creating the VM or its components: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting New-CustomVMWithDifferencingDisk function" -Level "INFO"
    }
}
