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
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return $reader.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            return "ERR:" + $r.ReadToEnd()
        }
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
            $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            return "ERR:" + $r.ReadToEnd()
        }
    }
}

# Strategy: Use dbdocs DAG which runs dbdocs CLI - it uses BashOperator internally
# First unpause it, add kubernetes_default connection, then trigger with real project name
# but injected command

# 1. Check kubernetes_default connection
Write-Host "=== kubernetes_default ==="
Write-Host (AF-Get "/api/v1/connections/kubernetes_default")

# 2. Get all connections - look for kubernetes type
Write-Host "`n=== ALL CONNECTIONS (conn_type filter) ==="
$all = AF-Get "/api/v1/connections?limit=200"
$all | Select-String '"conn_type"' | ForEach-Object { Write-Host $_.Line }

# 3. Try to create kubernetes_default connection pointing to our K8s
Write-Host "`n=== CREATE KUBE CONN ==="
$kube_body = '{"connection_id":"kubernetes_default","conn_type":"kubernetes","host":"https://10.9.100.10:6443","schema":"","login":"","password":"","port":null,"extra":"{\"in_cluster\": false, \"verify_ssl\": false}"}'
Write-Host (AF-Post "/api/v1/connections" $kube_body)

# 4. Now try dbdocs_build_dbml_dynamic with proper conf
# The DAG uses dbdocs CLI - find out what params it accepts
Write-Host "`n=== DBDOCS DAG SOURCE ==="
$token = "Ii9vcHQvYWlyZmxvdy9kYWdzL2Ntcy9CdXJlYXVfRHJvcF9GaWxlcy5weSI.s_rnTO7Z9XrdCVORZtiV8kVFuOA"
Write-Host (AF-Get "/api/v1/dagSources/$token")

# 5. Trigger dbdocs with valid params first to see what happens
Write-Host "`n=== TRIGGER dbdocs valid ==="
$ts = [DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
$body = "{`"conf`":{`"project`":`"testproject`",`"password`":`"`"},`"logical_date`":`"$ts`"}"

# First unpause
Write-Host (AF-Patch "/api/v1/dags/dbdocs_build_dbml_dynamic" '{"is_paused": false}')
Start-Sleep -Seconds 2
Write-Host (AF-Post "/api/v1/dags/dbdocs_build_dbml_dynamic/dagRuns" $body)
