#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

/usr/bin/sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.13.16.196 bash << 'REMOTECMD'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "=== INSTALL PSQL ==="
echo kutul0nc4t | sudo -S apt-get install -y postgresql-client 2>&1 | tail -3

echo "=== CHECK NUCLEUS REACHABLE ==="
timeout 5 bash -c 'echo > /dev/tcp/10.14.17.218/5502' 2>&1 && echo "NUCLEUS REACHABLE" || echo "NUCLEUS UNREACHABLE"

echo "=== CHECK MAIN DB ==="
timeout 5 bash -c 'echo > /dev/tcp/10.13.17.248/5501' 2>&1 && echo "MAINDB REACHABLE" || echo "MAINDB UNREACHABLE"

echo "=== NUCLEUS - DB SERVERS ==="
PGPASSWORD='HyperLink%Nuc#Acc5' timeout 10 psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A -c "SELECT DISTINCT ip_address, port FROM database_server ORDER BY ip_address, port" 2>&1

echo "=== NUCLEUS - TOTAL TENANTS ==="
PGPASSWORD='HyperLink%Nuc#Acc5' timeout 10 psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A -c "SELECT count(*) FROM application_database" 2>&1

echo "=== NUCLEUS - PAYMENT TABLES ==="
PGPASSWORD='HyperLink%Nuc#Acc5' timeout 10 psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND (table_name LIKE '%xendit%' OR table_name LIKE '%payment%' OR table_name LIKE '%xnd%')" 2>&1

echo "=== SAMPLE TENANT WITH DB SERVER ==="
PGPASSWORD='HyperLink%Nuc#Acc5' timeout 10 psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A -c "SELECT ad.unique_id, ad.company_name, ds.ip_address, ds.port FROM application_database ad LEFT JOIN database_server ds ON ad.database_server_id = ds.id ORDER BY ds.ip_address, ds.port LIMIT 20" 2>&1

echo "=== TRY TENANT DB - First server from Redis ==="
# Try connecting to 10.13.17.70 with NEO creds
PGPASSWORD='BJwx+sAC6jreaV45' timeout 10 psql -h 10.13.17.70 -p 5524 -U neo -l 2>&1 | head -20

echo "=== TRY TENANT DB - With nucleus creds ==="
PGPASSWORD='HyperLink%Nuc#Acc5' timeout 10 psql -h 10.13.17.70 -p 5524 -U nucleus -l 2>&1 | head -20

echo "=== DONE ==="
REMOTECMD
