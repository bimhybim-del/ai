#!/bin/bash
export PGPASSWORD="HyperLink%Nuc#Acc5"
DB_HOST="10.14.17.218"
DB_PORT="5502"

# Search specific tables that likely have Xendit keys
echo "=== APPLICATION DETAIL ==="
psql -h $DB_HOST -p $DB_PORT -U nucleus -d nucleus -t -c "SELECT * FROM application_detail LIMIT 5" 2>&1 | head -20

echo "=== APPLICATION INSTALL (Xendit apps) ==="
psql -h $DB_HOST -p $DB_PORT -U nucleus -d nucleus -t -c "SELECT column_name FROM information_schema.columns WHERE table_name='application_install'" 2>&1

echo "=== APP INSTALL XENDIT ==="
psql -h $DB_HOST -p $DB_PORT -U nucleus -d nucleus -t -c "SELECT id,application_id,database_id FROM application_install WHERE application_id IN (29753,37750,48662,49001) LIMIT 10" 2>&1

echo "=== APPLICATION WEBHOOK ==="
psql -h $DB_HOST -p $DB_PORT -U nucleus -d nucleus -t -c "SELECT * FROM application_webhook WHERE application_id IN (29753,37750,48662,49001)" 2>&1

echo "=== DEVELOPER ACCESS ==="
psql -h $DB_HOST -p $DB_PORT -U nucleus -d nucleus -t -c "SELECT column_name FROM information_schema.columns WHERE table_name='developer_access'" 2>&1
psql -h $DB_HOST -p $DB_PORT -U nucleus -d nucleus -t -c "SELECT * FROM developer_access LIMIT 5" 2>&1 | head -10

echo "=== SEARCH ALL TEXT FOR xnd_ ==="
for tbl in application application_detail application_install application_webhook developer_access data_access oauth_access_token; do
  cols=$(psql -h $DB_HOST -p $DB_PORT -U nucleus -d nucleus -t -c "SELECT column_name FROM information_schema.columns WHERE table_name='$tbl' AND data_type IN ('character varying','text')" 2>/dev/null | tr -d ' ')
  for col in $cols; do
    if [ -n "$col" ]; then
      hit=$(psql -h $DB_HOST -p $DB_PORT -U nucleus -d nucleus -t -c "SELECT count(*) FROM $tbl WHERE $col LIKE '%xnd_%'" 2>/dev/null | tr -d ' ')
      if [ "$hit" != "0" ] && [ -n "$hit" ]; then
        echo "HIT: $tbl.$col has $hit rows with xnd_"
        psql -h $DB_HOST -p $DB_PORT -U nucleus -d nucleus -t -c "SELECT $col FROM $tbl WHERE $col LIKE '%xnd_%' LIMIT 3" 2>/dev/null
      fi
    fi
  done
done
