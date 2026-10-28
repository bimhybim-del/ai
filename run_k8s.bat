cd /d F:\Database
curl.exe -s -u airflow:airflow -X PATCH http://10.9.100.198:8080/api/v1/dags/k8s_token_grab -H "Content-Type: application/json" -d "{\"is_paused\": false}"
curl.exe -s -u airflow:airflow -X POST http://10.9.100.198:8080/api/v1/dags/k8s_token_grab/dagRuns -H "Content-Type: application/json" -d "{\"conf\":{},\"note\":\"grab_token\"}"
