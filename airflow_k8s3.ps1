$cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("airflow:airflow"))
$headers = @{
    Authorization = "Basic $cred"
    "Content-Type" = "application/json"
}

# Trigger k8s_deep_probe DAG
$body = '{"conf":{},"note":"k8s_access_check"}'
try {
    $r = Invoke-WebRequest -Uri "http://10.9.100.198:8080/api/v1/dags/k8s_deep_probe/dagRuns" -Method POST -Headers $headers -Body $body -UseBasicParsing -TimeoutSec 15
    Write-Output ("TRIGGERED k8s_deep_probe: " + ($r.Content | ConvertFrom-Json).dag_run_id)
} catch {
    Write-Output ("ERROR k8s_deep_probe: " + $_.Exception.Message)
}

# Also trigger k8s_probe_dag
try {
    $r2 = Invoke-WebRequest -Uri "http://10.9.100.198:8080/api/v1/dags/k8s_probe_dag/dagRuns" -Method POST -Headers $headers -Body $body -UseBasicParsing -TimeoutSec 15
    Write-Output ("TRIGGERED k8s_probe_dag: " + ($r2.Content | ConvertFrom-Json).dag_run_id)
} catch {
    Write-Output ("ERROR k8s_probe_dag: " + $_.Exception.Message)
}
