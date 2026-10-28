Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAll : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAll
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$url = "https://10.9.100.47/v1/auth/login"
$body1 = '{"secret_key":"OjkmU+BtpVZ7VJlI4nO4uWafXUI3WVY4V9nIM6xZXs38Jmns+CvQAMlnTTutIXw7","source_application":"KPM"}'
$body2 = '{"secret_key":"j4Cfspn7XleRHWRI8MB3aE+/acOiho78h8Fq4kQxS/MlZpPLcyaLrpBonB5OfCvopT+nJWlUf1lHHQ==","source_application":"KPM"}'

foreach ($body in @($body1, $body2)) {
    try {
        $req = [System.Net.WebRequest]::Create($url)
        $req.Method = "POST"
        $req.ContentType = "application/json"
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
        $req.ContentLength = $bytes.Length
        $stream = $req.GetRequestStream()
        $stream.Write($bytes, 0, $bytes.Length)
        $stream.Close()
        $resp = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        Write-Host "SUCCESS:" $reader.ReadToEnd()
    } catch [System.Net.WebException] {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        Write-Host "ERROR:" $reader.ReadToEnd()
    }
}
