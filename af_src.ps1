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
        return "EXC:" + $_.Exception.Message
    }
}

# Get all DAGs with file_tokens
$dagsJson = AF-Get "/api/v1/dags?limit=200"
$dags = $dagsJson | ConvertFrom-Json

Write-Host "Total DAGs: $($dags.dags.Count)"

# Read source for each DAG - look for BashOperator, subprocess, KubernetesPodOperator
$interesting = @()
foreach ($dag in $dags.dags) {
    $token = $dag.file_token
    $src = AF-Get "/api/v1/dagSources/$token"
    if ($src -match "BashOperator|subprocess|os\.system|os\.popen|KubernetesPodOperator|DockerOperator|SSHOperator|exec\(|eval\(") {
        Write-Host "=== INTERESTING: $($dag.dag_id) ($($dag.fileloc)) ==="
        Write-Host $src
        Write-Host "---"
        $interesting += $dag.dag_id
    }
}

if ($interesting.Count -eq 0) {
    Write-Host "=== NO BASH/K8S OPERATOR FOUND ==="
    # Show dbdocs anyway
    Write-Host "`n=== dbdocs source ==="
    foreach ($dag in $dags.dags) {
        if ($dag.dag_id -eq "dbdocs_build_dbml_dynamic") {
            $src = AF-Get "/api/v1/dagSources/$($dag.file_token)"
            Write-Host $src
        }
    }
}

Write-Host "`n=== Interesting DAGs: $($interesting -join ', ') ==="
