cd /d F:\Database
curl.exe -s -u airflow:airflow -X POST http://10.9.100.198:8080/api/v1/connections -H "Content-Type: application/json" -d @k8s_conn.json
curl.exe -s -u airflow:airflow -X POST http://10.9.100.198:8080/api/v1/connections -H "Content-Type: application/json" -d @k8s_dev_conn.json
curl.exe -s -u airflow:airflow -X POST http://10.9.100.198:8080/api/v1/variables -H "Content-Type: application/json" -d @dag_v2_var.json
