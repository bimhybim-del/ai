Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAll : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAll
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# .133 resolves DNS internally, so use hostname directly
$urls = @(
    "https://dev-plat-auth.kbfinansia.com/v1/auth/login",
    "https://dev-platform-auth.kbfinansia.com/v1/auth/login"
)
$bodies = @(
    '{"secret_key":"OjkmU+BtpVZ7VJlI4nO4uWafXUI3WVY4V9nIM6xZXs38Jmns+CvQAMlnTTutIXw7","source_application":"KPM"}',
    '{"secret_key":"j4Cfspn7XleRHWRI8MB3aE+/acOiho78h8Fq4kQxS/MlZpPLcyaLrpBonB5OfCvopT+nJWlUf1lHHQ==","source_application":"KPM"}',
    '{"secret_key":"OjkmU+BtpVZ7VJlI4nO4uWafXUI3WVY4V9nIM6xZXs38Jmns+CvQAMlnTTutIXw7","source_application":"AIRFLOW"}',
    '{"secret_key":"j4Cfspn7XleRHWRI8MB3aE+/acOiho78h8Fq4kQxS/MlZpPLcyaLrpBonB5OfCvopT+nJWlUf1lHHQ==","source_application":"AIRFLOW"}'
)

foreach ($url in $urls) {
    foreach ($body in $bodies) {
        Write-Host "=== URL: $url | Body: $body ==="
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
            if ($_.Exception.Response) {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                Write-Host "RESPONSE:" $reader.ReadToEnd()
            } else {
                Write-Host "ERROR:" $_.Exception.Message
            }
        }
    }
}
