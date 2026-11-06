#!/bin/bash
H="-h 10.13.17.248 -p 5501"

echo "=== SEARCH PAYMENT TABLES IN ALL DBS ==="
export PGPASSWORD="BJwx+sAC6jreaV45"
for db in noxify venus neptune mercury gemini; do
  tables=$(psql $H -U neo -d $db -t -c "SELECT tablename FROM pg_tables WHERE schemaname='public' AND (tablename LIKE '%payment_register%' OR tablename LIKE '%api_key%' OR tablename LIKE '%xendit_key%')" 2>/dev/null | tr -d ' ' | grep -v '^$')
  [ -n "$tables" ] && echo "DB=$db: $tables"
done

echo "=== VENUS PAYMENT TABLES ==="
export PGPASSWORD="K6Yr4RV6jsBCjae4"
psql $H -U venus -d venus -t -c "SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename LIKE '%payment%'" 2>&1 | head -10

echo "=== VENUS BILLING_PAYMENT COUNT ==="
psql $H -U venus -d venus -t -c "SELECT count(*) FROM billing_payment" 2>&1

echo "=== VENUS BILLING_PAYMENT SAMPLE ==="
psql $H -U venus -d venus -t -c "SELECT id,substring(cast(payment_data as text),1,200) FROM billing_payment WHERE cast(payment_data as text) LIKE '%xnd_%' ORDER BY id DESC LIMIT 3" 2>&1

echo "=== NUCLEUS SEARCH ==="
export PGPASSWORD="HyperLink%Nuc#Acc5"
psql -h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t -c "SELECT tablename FROM pg_tables WHERE schemaname='public' AND (tablename LIKE '%payment%' OR tablename LIKE '%xendit%')" 2>&1
