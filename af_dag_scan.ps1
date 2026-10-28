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

# Get ALL DAGs with file tokens
$dagsJson = AF-Get "/api/v1/dags?limit=200"
$dags = ($dagsJson | ConvertFrom-Json).dags
Write-Host "Total DAGs: $($dags.Count)"

# Read all sources, look for:
# 1. subprocess with Variable.get
# 2. eval, exec, __import__
# 3. os.system, os.popen
# 4. KubernetesPodOperator (K8s exec)
# 5. SSHOperator
# 6. Connections that use passwords from variable

$found = @()
foreach ($dag in $dags) {
    $src = AF-Get "/api/v1/dagSources/$($dag.file_token)"
    if ($src -match "Variable\.get|Variable_get|exec\(|eval\(|__import__|os\.popen|popen\(|Popen\(|KubernetesPodOperator|kubernetes_pod|SSHOperator|SFTPOperator") {
        $found += @{dag=$dag.dag_id; fileloc=$dag.fileloc; src=$src}
        Write-Host "=== FOUND: $($dag.dag_id) | $($dag.fileloc) ==="
        Write-Host $src
        Write-Host "---END---"
    }
}

if ($found.Count -eq 0) {
    Write-Host "NO eval/exec/K8s found - checking deploy_kafka_connector..."
    foreach ($dag in $dags) {
        if ($dag.dag_id -match "kafka|deploy|confins_r3|bss|backup") {
            $src = AF-Get "/api/v1/dagSources/$($dag.file_token)"
            Write-Host "=== $($dag.dag_id) ==="
            Write-Host ($src.Substring(0, [Math]::Min($src.Length, 3000)))
            Write-Host "---"
        }
    }
}
