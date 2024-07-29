function Remove-IntuneMgmt {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OMADMPath,

        [Parameter(Mandatory = $true)]
        [string]$EnrollmentBasePath,

        [Parameter(Mandatory = $true)]
        [string]$TrackedBasePath,

        [Parameter(Mandatory = $true)]
        [string]$PolicyManagerBasePath,

        [Parameter(Mandatory = $true)]
        [string]$ProvisioningBasePath,

        [Parameter(Mandatory = $true)]
        [string]$CertCurrentUserPath,

        [Parameter(Mandatory = $true)]
        [string]$CertLocalMachinePath,

        [Parameter(Mandatory = $true)]
        [string]$TaskPathBase,

        [Parameter(Mandatory = $true)]
        [string]$MSDMProviderID,

        [Parameter(Mandatory = $true)]
        [string[]]$RegistryPathsToRemove,

        [Parameter(Mandatory = $true)]
        [string]$UserCertIssuer,

        [Parameter(Mandatory = $true)]
        [string[]]$DeviceCertIssuers
    )

    Begin {
        Write-EnhancedLog -Message "Starting Remove-IntuneMgmt function" -Level "INFO"
        Log-Params -Params @{
            OMADMPath              = $OMADMPath
            EnrollmentBasePath     = $EnrollmentBasePath
            TrackedBasePath        = $TrackedBasePath
            PolicyManagerBasePath  = $PolicyManagerBasePath
            ProvisioningBasePath   = $ProvisioningBasePath
            CertCurrentUserPath    = $CertCurrentUserPath
            CertLocalMachinePath   = $CertLocalMachinePath
            TaskPathBase           = $TaskPathBase
            MSDMProviderID         = $MSDMProviderID
            RegistryPathsToRemove  = $RegistryPathsToRemove
            UserCertIssuer         = $UserCertIssuer
            DeviceCertIssuers      = $DeviceCertIssuers
        }
    }

    Process {
        try {
            Write-EnhancedLog -Message "Checking Intune enrollment status" -Level "INFO"
            $Account = (Get-ItemProperty -Path $OMADMPath -ErrorAction SilentlyContinue).PSChildName

            $Enrolled = $true
            $EnrollmentPath = "$EnrollmentBasePath\$Account"
            $EnrollmentUPN = (Get-ItemProperty -Path $EnrollmentPath -ErrorAction SilentlyContinue).UPN
            $ProviderID = (Get-ItemProperty -Path $EnrollmentPath -ErrorAction SilentlyContinue).ProviderID

            if (-not $EnrollmentUPN -or $ProviderID -ne $MSDMProviderID) {
                $Enrolled = $false
            }

            if ($Enrolled) {
                Write-EnhancedLog -Message "Device is enrolled in Intune. Proceeding with unenrollment." -Level "INFO"

                # Delete Task Schedule tasks
                Get-ScheduledTask -TaskPath "$TaskPathBase\$Account\*" | Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

                # Delete registry keys
                foreach ($RegistryPath in $RegistryPathsToRemove) {
                    Remove-Item -Path "$RegistryPath\$Account" -Recurse -Force -ErrorAction SilentlyContinue
                }

                # Delete enrollment certificates
                $UserCerts = Get-ChildItem -Path $CertCurrentUserPath -Recurse
                $IntuneCerts = $UserCerts | Where-Object { $_.Issuer -eq $UserCertIssuer }
                foreach ($Cert in $IntuneCerts) {
                    $Cert | Remove-Item -Force
                }
                $DeviceCerts = Get-ChildItem -Path $CertLocalMachinePath -Recurse
                $IntuneCerts = $DeviceCerts | Where-Object { $DeviceCertIssuers -contains $_.Issuer }
                foreach ($Cert in $IntuneCerts) {
                    $Cert | Remove-Item -Force -ErrorAction SilentlyContinue
                }
            }
        } catch {
            Write-EnhancedLog -Message "An error occurred while removing Intune management: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Remove-IntuneMgmt function" -Level "INFO"
    }
}


# $RemoveIntuneMgmtParams = @{
#     OMADMPath              = "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*"
#     EnrollmentBasePath     = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments"
#     TrackedBasePath        = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked"
#     PolicyManagerBasePath  = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager"
#     ProvisioningBasePath   = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning"
#     CertCurrentUserPath    = "cert:\CurrentUser"
#     CertLocalMachinePath   = "cert:\LocalMachine"
#     TaskPathBase           = "\Microsoft\Windows\EnterpriseMgmt"
#     MSDMProviderID         = "MS DM Server"
#     RegistryPathsToRemove  = @(
#         "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments",
#         "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments\Status",
#         "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked",
#         "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled",
#         "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\Providers",
#         "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts",
#         "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Logger",
#         "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions"
#     )
#     UserCertIssuer         = "CN=SC_Online_Issuing"
#     DeviceCertIssuers      = @("CN=Microsoft Intune Root Certification Authority", "CN=Microsoft Intune MDM Device CA")
# }

# Remove-IntuneMgmt @RemoveIntuneMgmtParams
