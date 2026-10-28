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

# High-value connections to retrieve
$conn_ids = @(
    "platform-auth",
    "confins-r3-api",
    "confins_r3_foundation_pgb",
    "confins_r3_ar_pgb",
    "confins_r3_foundation",
    "confins_stg",
    "confins",
    "data_lake",
    "customer_domain",
    "kreditmu-api",
    "los",
    "sftp_conn_id",
    "kafka",
    "core_staging",
    "valdo_db",
    "rapindodb",
    "ficoms",
    "jis",
    "kplos",
    "pbk"
)

foreach ($cid in $conn_ids) {
    try {
        $req = [System.Net.WebRequest]::Create("$base/api/v1/connections/$cid")
        $req.Method = "GET"
        $req.Headers.Add("Authorization", "Basic $encoded")
        $resp = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        Write-Host "=== $cid ===" $reader.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $sc = [int]$_.Exception.Response.StatusCode
            Write-Host "=== $cid FAIL $sc ==="
        }
    }
}

# Also get DAGs list to find K8s-related DAGs
Write-Host "`n=== DAGs with kubernetes ==="
try {
    $req = [System.Net.WebRequest]::Create("$base/api/v1/dags?limit=200")
    $req.Method = "GET"
    $req.Headers.Add("Authorization", "Basic $encoded")
    $resp = $req.GetResponse()
    $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
    $content = $reader.ReadToEnd()
    # Print only DAG IDs
    $content | Select-String '"dag_id"' | ForEach-Object { Write-Host $_.Line }
} catch [System.Net.WebException] {}
