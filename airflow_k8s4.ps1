$cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("airflow:airflow"))
$headers = @{
    Authorization = "Basic $cred"
}

# Check k8s_deep_probe tasks
$r = Invoke-WebRequest -Uri "http://10.9.100.198:8080/api/v1/dags/k8s_deep_probe/dagRuns/manual__2026-10-28T06:14:44.643819+00:00/taskInstances" -Headers $headers -UseBasicParsing -TimeoutSec 15
$tasks = ($r.Content | ConvertFrom-Json).task_instances
foreach ($t in $tasks) {
    Write-Output ("DEEP_PROBE: " + $t.task_id + " = " + $t.state)
}

# Check k8s_probe_dag tasks
$r2 = Invoke-WebRequest -Uri "http://10.9.100.198:8080/api/v1/dags/k8s_probe_dag/dagRuns/manual__2026-10-28T06:14:45.112179+00:00/taskInstances" -Headers $headers -UseBasicParsing -TimeoutSec 15
$tasks2 = ($r2.Content | ConvertFrom-Json).task_instances
foreach ($t2 in $tasks2) {
    Write-Output ("PROBE_DAG: " + $t2.task_id + " = " + $t2.state)
}
