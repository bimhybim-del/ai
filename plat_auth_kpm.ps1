Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAll : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAll
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$url = "https://dev-plat-auth.kbfinansia.com/v1/auth/login"

# Try all combos
$combos = @(
    @{secret_key="j4Cfspn7XleRHWRI8MB3aE+/acOiho78h8Fq4kQxS/MlZpPLcyaLrpBonB5OfCvopT+nJWlUf1lHHQ=="; source_application="PAYMENT-POINT-API"},
    @{secret_key="OjkmU+BtpVZ7VJlI4nO4uWafXUI3WVY4V9nIM6xZXs38Jmns+CvQAMlnTTutIXw7"; source_application="PAYMENT-POINT-API"},
    @{secret_key="j4Cfspn7XleRHWRI8MB3aE+/acOiho78h8Fq4kQxS/MlZpPLcyaLrpBonB5OfCvopT+nJWlUf1lHHQ=="; source_application="KPM"},
    @{secret_key="SVVieUNlT3VvNFp3UlBHd1BhY3hSUWdMRGQzTi9hYm9memhnRlFyTjJ2NFNZUz0="; source_application="PAYMENT-POINT-API"},
    @{secret_key="SVVieUNlT3VvNFp3UlBHd1BhY3hSUWdMRGQzTi9hYm9memhnRlFyTjJ2NFNZUz0="; source_application="KPM"},
    @{secret_key="JiPhNSrE30opce1qYnzb8jSmsC60rGAw0LvcyxUwC/+EiGMjFu2i0GN06ktBdi3W"; source_application="PAYMENT-POINT-API"},
    @{secret_key="JiPhNSrE30opce1qYnzb8jSmsC60rGAw0LvcyxUwC/+EiGMjFu2i0GN06ktBdi3W"; source_application="KPM"}
)

foreach ($combo in $combos) {
    $body = "{`"secret_key`":`"$($combo.secret_key)`",`"source_application`":`"$($combo.source_application)`"}"
    try {
        $req = [System.Net.WebRequest]::Create($url)
        $req.Method = "POST"
        $req.ContentType = "application/json"
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
        $req.ContentLength = $bytes.Length
        $s = $req.GetRequestStream(); $s.Write($bytes,0,$bytes.Length); $s.Close()
        $resp = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        Write-Host "SUCCESS $($combo.source_application): " $reader.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $sc = [int]$_.Exception.Response.StatusCode
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            Write-Host "FAIL $sc ($($combo.source_application)/$($combo.secret_key.Substring(0,15))): " $reader.ReadToEnd()
        }
    }
}
