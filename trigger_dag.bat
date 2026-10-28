cd /d F:\Database
curl.exe -s -u airflow:airflow -X POST http://10.9.100.198:8080/api/v1/dags/maintenance_logs_cleanup/dagRuns -H "Content-Type: application/json" -d @trig.json
