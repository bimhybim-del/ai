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

function AF-GetAccept($path, $accept) {
    try {
        $req = [System.Net.WebRequest]::Create("$base$path")
        $req.Method = "GET"
        $req.Headers.Add("Authorization", "Basic $encoded")
        $req.Accept = $accept
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

# Get dbdocs source
$dagsJson = AF-GetAccept "/api/v1/dags?limit=200" "application/json"
$dags = ($dagsJson | ConvertFrom-Json).dags

# Find dbdocs and other interesting DAGs
$targetDags = $dags | Where-Object { $_.dag_id -match "dbdocs|k8s|kubernetes|kube|ssh|exec|shell|bash|script|deploy|run_command|command" }
Write-Host "=== TARGET DAGS ==="
foreach ($dag in $targetDags) {
    Write-Host "$($dag.dag_id) | $($dag.fileloc)"
    $src = AF-GetAccept "/api/v1/dagSources/$($dag.file_token)" "text/plain"
    Write-Host $src
    Write-Host "---"
}

# Read all connections
Write-Host "`n=== ALL CONNECTIONS (with extras) ==="
$connsJson = AF-GetAccept "/api/v1/connections?limit=200" "application/json"
Write-Host $connsJson

# Check if kubernetes connection exists
$conns = ($connsJson | ConvertFrom-Json).connections
$k8sConns = $conns | Where-Object { $_.conn_type -eq "kubernetes" -or $_.connection_id -match "kube|k8s" }
Write-Host "`n=== K8S CONNECTIONS ==="
foreach ($c in $k8sConns) {
    Write-Host "ID: $($c.connection_id)"
    Write-Host "Type: $($c.conn_type)"
    Write-Host "Host: $($c.host)"
    Write-Host "Extra: $($c.extra)"
}

# Check Airflow connections for SFTP/SSH type
Write-Host "`n=== SSH CONNECTIONS ==="
$sshConns = $conns | Where-Object { $_.conn_type -eq "ssh" -or $_.conn_type -eq "sftp" }
foreach ($c in $sshConns) {
    Write-Host "ID: $($c.connection_id) | Host: $($c.host) | User: $($c.login) | Extra: $($c.extra)"
}
