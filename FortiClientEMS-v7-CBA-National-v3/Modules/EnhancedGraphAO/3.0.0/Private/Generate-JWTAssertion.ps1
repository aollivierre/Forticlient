function Generate-JWTAssertion {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$jwtHeader,
        [Parameter(Mandatory = $true)]
        [hashtable]$jwtPayload,
        [Parameter(Mandatory = $true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$cert
    )

    $jwtHeaderJson = ($jwtHeader | ConvertTo-Json -Compress)
    $jwtPayloadJson = ($jwtPayload | ConvertTo-Json -Compress)
    $jwtHeaderEncoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($jwtHeaderJson)).TrimEnd('=').Replace('+', '-').Replace('/', '_')
    $jwtPayloadEncoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($jwtPayloadJson)).TrimEnd('=').Replace('+', '-').Replace('/', '_')

    $dataToSign = "$jwtHeaderEncoded.$jwtPayloadEncoded"
    $sha256 = [Security.Cryptography.SHA256]::Create()
    $hash = $sha256.ComputeHash([Text.Encoding]::UTF8.GetBytes($dataToSign))

    $rsa = [Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($cert)
    $signature = [Convert]::ToBase64String($rsa.SignHash($hash, [Security.Cryptography.HashAlgorithmName]::SHA256, [Security.Cryptography.RSASignaturePadding]::Pkcs1)).TrimEnd('=').Replace('+', '-').Replace('/', '_')

    return "$dataToSign.$signature"
}