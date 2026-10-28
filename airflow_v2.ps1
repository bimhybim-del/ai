Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAll : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAll
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$base = "https://dev-airflow.kbfinansia.com"
$jar = New-Object System.Net.CookieContainer

# Try Basic Auth first - Airflow 2.x supports basic auth
$creds_list = @(
    "admin:admin",
    "admin:@F1n4ns14*2019",
    "airflow:airflow",
    "airflow:@F1n4ns14*2019",
    "admin:kreditplus",
    "admin:Kreditplus123"
)

foreach ($cred in $creds_list) {
    $parts = $cred.Split(":",2)
    $encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($cred))
    try {
        $req = [System.Net.WebRequest]::Create("$base/api/v1/variables?limit=100")
        $req.Method = "GET"
        $req.Headers.Add("Authorization", "Basic $encoded")
        $req.CookieContainer = $jar
        $resp = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $content = $reader.ReadToEnd()
        Write-Host "SUCCESS ($cred): $content"
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $sc = [int]$_.Exception.Response.StatusCode
            Write-Host "FAIL $sc ($cred)"
        }
    }
}

# Also try to get variables without auth (public)
try {
    $req = [System.Net.WebRequest]::Create("$base/api/v1/variables?limit=100")
    $req.Method = "GET"
    $resp = $req.GetResponse()
    $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
    Write-Host "NAUTH: " $reader.ReadToEnd()
} catch [System.Net.WebException] {
    if ($_.Exception.Response) {
        $sc = [int]$_.Exception.Response.StatusCode
        Write-Host "NAUTH FAIL: $sc"
    }
}
