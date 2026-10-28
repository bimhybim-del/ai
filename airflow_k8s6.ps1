$cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("airflow:airflow"))
$headers = @{
    Authorization = "Basic $cred"
}
$r = Invoke-WebRequest -Uri "http://10.9.100.198:8080/api/v1/dags/k8s_deep_probe/dagRuns/manual__2026-10-28T06:14:44.643819+00:00/taskInstances/deep_probe/logs/1" -Headers $headers -UseBasicParsing -TimeoutSec 15
$r.Content
