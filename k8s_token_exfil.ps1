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

function AF-Patch($path, $body) {
    try {
        $req = [System.Net.WebRequest]::Create("$base$path")
        $req.Method = "PATCH"
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

# Step 1: Get all DAGs to find Python exec ones
Write-Host "=== LIST ALL DAGS ==="
$dags = AF-Get "/api/v1/dags?limit=100"
Write-Host $dags

# Step 2: Read dbdocs source
Write-Host "`n=== DBDOCS SOURCE ==="
$src = AF-Get "/api/v1/dagSources/.eJxT0s8vKNFPzCxKy8kv109JTC_WT0lKyU8ujk8qzcxJiU9Jys2JT6nMS8zNTMYto1dQqQQAHWkcbQ.cjN1Cn_noKb-noaGqugUPwtGI8w"
Write-Host $src

# Step 3: List all task instances to understand DAG structure
Write-Host "`n=== DBDOCS TASKS ==="
Write-Host (AF-Get "/api/v1/dags/dbdocs_build_dbml_dynamic/tasks")

# Step 4: Check existing dag runs
Write-Host "`n=== EXISTING RUNS ==="
Write-Host (AF-Get "/api/v1/dags/dbdocs_build_dbml_dynamic/dagRuns?limit=10")

# Step 5: Check Airflow config for DAG folder location
Write-Host "`n=== CONFIG ==="
Write-Host (AF-Get "/api/v1/config")

# Step 6: Check health and info
Write-Host "`n=== INFO ==="
Write-Host (AF-Get "/api/v1/version")

# Step 7: Try to list plugins
Write-Host "`n=== PLUGINS ==="
Write-Host (AF-Get "/api/v1/plugins"))

# Step 8: Providers list 
Write-Host "`n=== PROVIDERS ==="
Write-Host (AF-Get "/api/v1/providers")
