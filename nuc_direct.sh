#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

/usr/bin/sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.13.16.196 bash << 'REMOTECMD'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "=== NUCLEUS DB SERVERS ==="
PGPASSWORD='HyperLink%Nuc#Acc5' psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A -c "SELECT DISTINCT ip_address, port, db_tool FROM database_server ORDER BY ip_address" 2>&1

echo "=== TOTAL TENANT DBS ==="
PGPASSWORD='HyperLink%Nuc#Acc5' psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A -c "SELECT count(*) FROM application_database" 2>&1

echo "=== SAMPLE TENANT DBS (10) ==="
PGPASSWORD='HyperLink%Nuc#Acc5' psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A -c "SELECT ad.unique_id, ad.company_name, ds.ip_address, ds.port FROM application_database ad JOIN database_server ds ON ad.database_server_id = ds.id LIMIT 10" 2>&1

echo "=== TABLES WITH XENDIT ==="
PGPASSWORD='HyperLink%Nuc#Acc5' psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND (table_name LIKE '%xendit%' OR table_name LIKE '%payment%' OR table_name LIKE '%xnd%')" 2>&1

echo "=== REDIS DB1 - sagitarius-credential ==="
redis-cli -h 10.13.16.156 -p 6379 -n 1 type sagitarius-credential 2>&1
redis-cli -h 10.13.16.156 -p 6379 -n 1 hgetall sagitarius-credential 2>&1 | head -20

echo "=== REDIS DB1 - accurate-api-token-validity-cache ==="
redis-cli -h 10.13.16.156 -p 6379 -n 1 type accurate-api-token-validity-cache 2>&1
redis-cli -h 10.13.16.156 -p 6379 -n 1 --scan --pattern 'accurate-api-token*' 2>/dev/null | head -10

echo "=== DONE ==="
REMOTECMD
