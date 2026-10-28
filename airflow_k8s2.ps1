$cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("airflow:airflow"))
$headers = @{
    Authorization = "Basic $cred"
    "Content-Type" = "application/json"
}

# First - try to delete the lock file by creating a DAG via serialized DB
# Or better - check DAG list for other DAGs with BashOperator
$r = Invoke-WebRequest -Uri "http://10.9.100.198:8080/api/v1/dags?limit=100" -Headers $headers -UseBasicParsing -TimeoutSec 15
$dags = ($r.Content | ConvertFrom-Json).dags
foreach ($d in $dags) {
    if ($d.is_paused -eq $false) {
        Write-Output ("ACTIVE: " + $d.dag_id + " | " + $d.fileloc)
    }
}
