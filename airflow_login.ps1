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

# Try login via REST API first (Airflow 2.x)
$creds_list = @(
    @{username="admin"; password="admin"},
    @{username="admin"; password="@F1n4ns14*2019"},
    @{username="airflow"; password="airflow"},
    @{username="airflow"; password="@F1n4ns14*2019"}
)

foreach ($cred in $creds_list) {
    try {
        $loginBody = "{`"username`":`"$($cred.username)`",`"password`":`"$($cred.password)`"}"
        $req = [System.Net.WebRequest]::Create("$base/api/v1/security/login")
        $req.Method = "POST"
        $req.ContentType = "application/json"
        $req.CookieContainer = $jar
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($loginBody)
        $req.ContentLength = $bytes.Length
        $s = $req.GetRequestStream(); $s.Write($bytes,0,$bytes.Length); $s.Close()
        $resp = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $content = $reader.ReadToEnd()
        Write-Host "LOGIN SUCCESS ($($cred.username)):$content"
        break
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            Write-Host "LOGIN FAIL ($($cred.username)/$($cred.password)): " $reader.ReadToEnd()
        }
    }
}
