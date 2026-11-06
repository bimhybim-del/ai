#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

echo "=== NUCLEUS DB - DATABASE SERVERS ==="
PGPASSWORD='HyperLink%Nuc#Acc5' psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A << 'SQL'
-- List all database servers
SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_name LIKE '%database%' OR table_name LIKE '%server%' OR table_name LIKE '%tenant%' ORDER BY table_name;
SQL

echo "=== NUCLEUS - application_database table ==="
PGPASSWORD='HyperLink%Nuc#Acc5' psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A << 'SQL'
SELECT column_name FROM information_schema.columns WHERE table_name='application_database' AND table_schema='public' ORDER BY ordinal_position;
SQL

echo "=== NUCLEUS - database_server table ==="
PGPASSWORD='HyperLink%Nuc#Acc5' psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A << 'SQL'
SELECT column_name FROM information_schema.columns WHERE table_name='database_server' AND table_schema='public' ORDER BY ordinal_position;
SQL

echo "=== ALL DATABASE SERVERS (unique IPs) ==="
PGPASSWORD='HyperLink%Nuc#Acc5' psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A << 'SQL'
SELECT DISTINCT ip_address, port, db_tool FROM database_server ORDER BY ip_address;
SQL

echo "=== TOTAL TENANT DATABASES ==="
PGPASSWORD='HyperLink%Nuc#Acc5' psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -A << 'SQL'
SELECT count(*) FROM application_database;
SQL

echo "=== DONE ==="
