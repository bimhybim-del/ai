@echo off
cd /d F:\Database
curl.exe -s -u airflow:airflow -X POST http://10.9.100.198:8080/api/v1/connections -H "Content-Type: application/json" -d @conn_prod.json
echo ---C1---
curl.exe -s -u airflow:airflow -X POST http://10.9.100.198:8080/api/v1/connections -H "Content-Type: application/json" -d @conn_dev.json
echo ---C2---
