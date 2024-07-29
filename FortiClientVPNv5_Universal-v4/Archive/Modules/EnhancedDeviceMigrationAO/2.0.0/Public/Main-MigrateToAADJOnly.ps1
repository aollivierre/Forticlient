function Main-MigrateToAADJOnly {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$PPKGName,
        
        [Parameter(Mandatory = $false)]
        [string]$DomainLeaveUser,
        
        [Parameter(Mandatory = $false)]
        [string]$DomainLeavePassword,
        
        [Parameter(Mandatory = $true)]
        [string]$TempUser,
        
        [Parameter(Mandatory = $true)]
        [string]$TempUserPassword,
        
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )

    Begin {
        Write-EnhancedLog -Message "Starting Main-MigrateToAADJOnly function" -Level "INFO"
        Log-Params -Params @{
            PPKGName            = $PPKGName;
            DomainLeaveUser     = $DomainLeaveUser;
            DomainLeavePassword = $DomainLeavePassword;
            TempUser            = $TempUser;
            TempUserPassword    = $TempUserPassword;
            ScriptPath          = $ScriptPath;
        }

        # Initialize steps
        $global:steps = @()
        Add-Step -description "Testing provisioning package" -action { 

            $TestProvisioningPackParams = @{
                PPKGName = $PPKGName
            }

            Test-ProvisioningPack @TestProvisioningPackParams

        }
        # Add-Step -description "Adding local user" -action { Add-LocalUser -TempUser $TempUser -TempUserPassword $TempUserPassword }
        Add-Step -description "Adding local user" -action { 
            $AddLocalUserParams = @{
                TempUser         = $TempUser
                TempUserPassword = $TempUserPassword
                Description      = "account for autologin"
                Group            = "Administrators"
            }
            
            # Example usage with splatting
            Add-LocalUser @AddLocalUserParams
        }
        Add-Step -description "Setting autologin" -action { 


            # Example usage with splatting
            $SetAutologinParams = @{
                TempUser            = $TempUser
                TempUserPassword    = $TempUserPassword
                RegPath             = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
                AutoAdminLogonName  = 'AutoAdminLogon'
                AutoAdminLogonValue = '1'
                DefaultUsernameName = 'DefaultUsername'
                DefaultPasswordName = 'DefaultPassword'
            }

            Set-Autologin @SetAutologinParams

        }
        Add-Step -description "Disabling OOBE privacy" -action { 


            # Example usage with splatting
            $DisableOOBEPrivacyParams = @{
                OOBERegistryPath      = 'HKLM:\Software\Policies\Microsoft\Windows\OOBE'
                OOBEName              = 'DisablePrivacyExperience'
                OOBEValue             = '1'
                AnimationRegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
                AnimationName         = 'EnableFirstLogonAnimation'
                AnimationValue        = '0'
                LockRegistryPath      = 'HKLM:\Software\Policies\Microsoft\Windows\Personalization'
                LockName              = 'NoLockScreen'
                LockValue             = '1'
            }

            Disable-OOBEPrivacy @DisableOOBEPrivacyParams

        }
        Add-Step -description "Setting RunOnce script" -action { 


            # Example usage with splatting
            $SetRunOnceParams = @{
                ScriptPath      = $ScriptPath
                RunOnceKey      = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
                PowershellPath  = "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe"
                ExecutionPolicy = "Unrestricted"
                RunOnceName     = "NextRun"
            }

            Set-RunOnce @SetRunOnceParams

        }
        Add-Step -description "Suspending BitLocker With Reboot Count" -action {

            # Example usage with splatting
            $SuspendBitLockerWithRebootParams = @{
                MountPoint  = "C:"
                RebootCount = 3
            }

            Suspend-BitLockerWithReboot @SuspendBitLockerWithRebootParams

        }
        Add-Step -description "Removing Intune management" -action { 

            # $RemoveCompanyPortalParams = @{
            #     AppxPackageName = "Microsoft.CompanyPortal"
            # }

            # Remove-CompanyPortal @RemoveCompanyPortalParams

            $RemoveIntuneMgmtParams = @{
                OMADMPath              = "HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\*"
                EnrollmentBasePath     = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments"
                TrackedBasePath        = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked"
                PolicyManagerBasePath  = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager"
                ProvisioningBasePath   = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning"
                CertCurrentUserPath    = "cert:\CurrentUser"
                CertLocalMachinePath   = "cert:\LocalMachine"
                TaskPathBase           = "\Microsoft\Windows\EnterpriseMgmt"
                MSDMProviderID         = "MS DM Server"
                RegistryPathsToRemove  = @(
                    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments",
                    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments\Status",
                    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked",
                    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled",
                    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\Providers",
                    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts",
                    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Logger",
                    "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions"
                )
                UserCertIssuer         = "CN=SC_Online_Issuing"
                DeviceCertIssuers      = @("CN=Microsoft Intune Root Certification Authority", "CN=Microsoft Intune MDM Device CA")
            }

            Remove-IntuneMgmt @RemoveIntuneMgmtParams

        }
        Add-Step -description "Removing hybrid join" -action { Remove-Hybrid }
        Add-Step -description "Removing AD join" -action { 


            $RemoveADJoinParams = @{
                # DomainLeaveUser     = $DomainLeaveUser
                # DomainLeavePassword = $DomainLeavePassword
                TempUser            = $TempUser
                TempUserPassword    = $TempUserPassword
                ComputerName        = "localhost"
                TaskName            = "AADM Launch PSADT for Interactive Migration"
            }
            
            Remove-ADJoin @RemoveADJoinParams

        }
    }

    Process {
        try {
            foreach ($step in $global:steps) {
                Log-And-Execute-Step -Step $step
            }
        }
        catch {
            Write-EnhancedLog -Message "An error occurred: $($_.Exception.Message)" -Level "ERROR"
            Handle-Error -ErrorRecord $_
        }
    }

    End {
        Write-EnhancedLog -Message "Exiting Main-MigrateToAADJOnly function" -Level "INFO"
    }
}

# $MainMigrateParams = @{
#     PPKGName            = "YourProvisioningPackName"
#     DomainLeaveUser     = "YourDomainUser"
#     DomainLeavePassword = "YourDomainPassword"
#     TempUser            = "YourTempUser"
#     TempUserPassword    = "YourTempUserPassword"
#     ScriptPath          = "C:\ProgramData\AADMigration\Scripts\PostRunOnce.ps1"
# }

# Main-MigrateToAADJOnly @MainMigrateParams
