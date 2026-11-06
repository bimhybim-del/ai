#!/bin/bash
export PGPASSWORD="HyperLink%Nuc#Acc5"
DB="-h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t"

echo "=== ALL XENDIT/PAYMENT APPS WITH FULL DETAILS ==="
psql $DB -c "SELECT id,name,api_key,secret_key,signature_secret,appkey,status,free_application,add_on_application,api_token_scope,enable_api_token FROM application WHERE lower(name) LIKE '%xendit%' OR lower(name) LIKE '%payment%' OR lower(name) LIKE '%neo%' OR id IN (29753,37750,48662,49001) ORDER BY id" 2>&1

echo "=== APPS WITH api_token_scope NOT NULL ==="
psql $DB -c "SELECT id,name,api_token_scope,enable_api_token FROM application WHERE api_token_scope IS NOT NULL AND api_token_scope != '' LIMIT 20" 2>&1

echo "=== APPS WITH enable_api_token = true ==="
psql $DB -c "SELECT id,name,api_key,secret_key,api_token_scope FROM application WHERE enable_api_token = true LIMIT 20" 2>&1

echo "=== INTERNAL/ADMIN APPS ==="
psql $DB -c "SELECT id,name,api_key,secret_key,status FROM application WHERE lower(name) LIKE '%admin%' OR lower(name) LIKE '%internal%' OR lower(name) LIKE '%system%' OR lower(name) LIKE '%master%' OR lower(name) LIKE '%platform%'" 2>&1
