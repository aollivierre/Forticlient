function Convert-RsaParametersToPem {
    param (
        [Parameter(Mandatory = $true)]
        [System.Security.Cryptography.RSAParameters]$rsaParameters
    )

    $builder = [System.Text.StringBuilder]::new()

    $builder.AppendLine("-----BEGIN RSA PRIVATE KEY-----") | Out-Null

    # Combine all RSA parameters and convert them to Base64
    $params = @(
        $rsaParameters.Modulus,
        $rsaParameters.Exponent,
        $rsaParameters.D,
        $rsaParameters.P,
        $rsaParameters.Q,
        $rsaParameters.DP,
        $rsaParameters.DQ,
        $rsaParameters.InverseQ
    )

    foreach ($param in $params) {
        $b64 = [System.Convert]::ToBase64String($param)
        $builder.AppendLine($b64) | Out-Null
    }

    $builder.AppendLine("-----END RSA PRIVATE KEY-----") | Out-Null

    return $builder.ToString()
}