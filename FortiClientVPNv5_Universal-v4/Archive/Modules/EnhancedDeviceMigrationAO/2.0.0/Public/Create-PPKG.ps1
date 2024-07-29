function Create-PPKG {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ICDPath,

        [Parameter(Mandatory = $true)]
        [string]$CustomizationXMLPath,

        [Parameter(Mandatory = $true)]
        [string]$PackagePath,

        [Parameter(Mandatory = $false)]
        [string]$ProductName,

        [Parameter(Mandatory = $false)]
        [string]$StoreFile,

        [Parameter(Mandatory = $false)]
        [string]$MSPackageRoot,

        [Parameter(Mandatory = $false)]
        [string]$OEMInputXML,

        [Parameter(Mandatory = $false)]
        [hashtable]$Variables,

        [Parameter(Mandatory = $false)]
        [bool]$Encrypted = $false,

        [Parameter(Mandatory = $false)]
        [bool]$Overwrite = $true
    )

    Begin {
        Write-EnhancedLog -Message "Starting Create-PPKG function" -Level "INFO"
        Log-Params -Params @{
            ICDPath = $ICDPath
            CustomizationXMLPath = $CustomizationXMLPath
            PackagePath = $PackagePath
            ProductName = $ProductName
            StoreFile = $StoreFile
            MSPackageRoot = $MSPackageRoot
            OEMInputXML = $OEMInputXML
            Variables = $Variables
            Encrypted = $Encrypted
            Overwrite = $Overwrite
        }

        # Ensure ICD.exe exists
        if (-not (Test-Path -Path $ICDPath)) {
            throw "ICD.exe not found at: $ICDPath"
        }

        # Ensure Customization XML file exists
        if (-not (Test-Path -Path $CustomizationXMLPath)) {
            throw "Customization XML file not found at: $CustomizationXMLPath"
        }
    }

    Process {
        try {
            # Build the command line arguments using a list
            $ICD_args = [System.Collections.Generic.List[string]]::new()
            $ICD_args.Add("/Build-ProvisioningPackage")
            $ICD_args.Add("/CustomizationXML:`"$CustomizationXMLPath`"")
            $ICD_args.Add("/PackagePath:`"$PackagePath`"")

            if ($Encrypted) {
                $ICD_args.Add("+Encrypted")
            } else {
                $ICD_args.Add("-Encrypted")
            }

            if ($Overwrite) {
                $ICD_args.Add("+Overwrite")
            } else {
                $ICD_args.Add("-Overwrite")
            }

            if ($ProductName) {
                $ICD_args.Add("/ProductName:`"$ProductName`"")
            }

            if ($StoreFile) {
                $ICD_args.Add("/StoreFile:`"$StoreFile`"")
            }

            if ($MSPackageRoot) {
                $ICD_args.Add("/MSPackageRoot:`"$MSPackageRoot`"")
            }

            if ($OEMInputXML) {
                $ICD_args.Add("/OEMInputXML:`"$OEMInputXML`"")
            }

            if ($Variables) {
                foreach ($key in $Variables.Keys) {
                    $ICD_args.Add("/Variables:`"$key=$($Variables[$key])`"")
                }
            }

            $ICD_args_string = $ICD_args -join " "
            Write-EnhancedLog -Message "Running ICD.exe with arguments: $ICD_args_string" -Level "INFO"
            Start-Process -FilePath $ICDPath -ArgumentList $ICD_args_string -Wait -NoNewWindow

        } catch {
            Write-EnhancedLog -Message "An error occurred while processing the Create-PPKG function: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Create-PPKG function" -Level "INFO"
    }
}

# Example usage
# $ppkgParams = @{
#     ICDPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Imaging and Configuration Designer\x86\ICD.exe"
#     CustomizationXMLPath = "C:\code\CB\Entra\DeviceMigration\Files\customizations.xml"
#     PackagePath = "C:\code\CB\Entra\DeviceMigration\Files\ProvisioningPackage.ppkg"
#     Encrypted = $false
#     Overwrite = $true
# }

# Create-PPKG @ppkgParams
