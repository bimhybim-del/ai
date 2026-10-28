$cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("airflow:airflow"))
$headers = @{
    Authorization = "Basic $cred"
}

# Read k8s_deep_probe log
Write-Output "=== K8S_DEEP_PROBE LOG ==="
$r = Invoke-WebRequest -Uri "http://10.9.100.198:8080/api/v1/dags/k8s_deep_probe/dagRuns/manual__2026-10-28T06:14:44.643819+00:00/taskInstances/deep_probe/logs/1" -Headers $headers -UseBasicParsing -TimeoutSec 15
$log = ($r.Content | ConvertFrom-Json).content
# Extract just the command output lines
$lines = $log -split '\\n'
foreach ($line in $lines) {
    if ($line -match 'INFO - Output:' -or $line -match 'subprocess.*INFO' -and $line -notmatch 'Running command' -and $line -notmatch 'Tmp dir') {
        Write-Output $line
    }
}

Write-Output ""
Write-Output "=== K8S_PROBE_DAG LOG ==="
$r2 = Invoke-WebRequest -Uri "http://10.9.100.198:8080/api/v1/dags/k8s_probe_dag/dagRuns/manual__2026-10-28T06:14:45.112179+00:00/taskInstances/probe/logs/1" -Headers $headers -UseBasicParsing -TimeoutSec 15
$log2 = ($r2.Content | ConvertFrom-Json).content
$lines2 = $log2 -split '\\n'
foreach ($line2 in $lines2) {
    if ($line2 -match 'subprocess.*INFO') {
        Write-Output $line2
    }
}
