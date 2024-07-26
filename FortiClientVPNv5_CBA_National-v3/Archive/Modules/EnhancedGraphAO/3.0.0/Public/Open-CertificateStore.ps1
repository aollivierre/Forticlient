function Open-CertificateStore {
    if (Is-ServerCore) {
        Write-Output "Running on Windows Server Core. Skipping opening of certificate manager."
    } else {
        # Open the certificate store
        Start-Process certmgr.msc
    }
}