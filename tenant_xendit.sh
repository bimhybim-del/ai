#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

/usr/bin/sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.13.16.196 bash << 'REMOTECMD'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "=== INSTALL PSQL IF MISSING ==="
which psql >/dev/null 2>&1 || (echo kutul0nc4t | sudo -S apt-get install -y postgresql-client 2>&1 | tail -3)

echo "=== TRY TENANT DB 10.13.17.70:5549 ==="
# Try with neo credentials
PGPASSWORD='BJwx+sAC6jreaV45' timeout 10 psql -h 10.13.17.70 -p 5549 -U neo -c "SELECT datname FROM pg_database WHERE datistemplate=false LIMIT 20" 2>&1

echo "=== TRY WITH accurate user ==="
# Accurate app likely has its own DB user
PGPASSWORD='Look@Me#729' timeout 10 psql -h 10.13.17.70 -p 5549 -U accurate -c "SELECT datname FROM pg_database WHERE datistemplate=false LIMIT 20" 2>&1

echo "=== GET TENANT DB NAME FROM NUCLEUS ==="
# First get what database name a tenant uses
PGPASSWORD='HyperLink%Nuc#Acc5' timeout 10 psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A -c "SELECT ad.unique_id, ad.alias, ds.ip_address, ds.port FROM application_database ad JOIN database_server ds ON ad.database_server_id = ds.id WHERE ds.ip_address='10.13.17.70' AND ds.port=5549 LIMIT 5" 2>&1

echo "=== NUCLEUS - application_database COLUMNS ==="
PGPASSWORD='HyperLink%Nuc#Acc5' timeout 10 psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A -c "SELECT column_name FROM information_schema.columns WHERE table_name='application_database' ORDER BY ordinal_position" 2>&1

echo "=== DONE ==="
REMOTECMD
