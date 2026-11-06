#!/bin/bash
H="-h 10.13.17.248 -p 5501 -t"

check_db() {
  local db=$1 user=$2 pass=$3
  export PGPASSWORD="$pass"
  for tbl in $(psql $H -U $user -d $db -c "SELECT tablename FROM pg_tables WHERE schemaname='public'" 2>/dev/null | tr -d ' ' | grep -v '^$'); do
    for col in $(psql $H -U $user -d $db -c "SELECT column_name FROM information_schema.columns WHERE table_name='$tbl' AND data_type IN ('character varying','text')" 2>/dev/null | tr -d ' ' | grep -v '^$'); do
      cnt=$(psql $H -U $user -d $db -c "SELECT count(*) FROM \"$tbl\" WHERE \"$col\" LIKE '%xnd_production%'" 2>/dev/null | tr -d ' ' | grep -v '^$' | head -1)
      if [ "$cnt" != "0" ] && [ -n "$cnt" ]; then
        echo "FOUND: $db.$tbl.$col = $cnt rows"
        psql $H -U $user -d $db -c "SELECT substring(\"$col\",1,80) FROM \"$tbl\" WHERE \"$col\" LIKE '%xnd_production%' LIMIT 3" 2>/dev/null
      fi
    done
  done
}

check_db neo neo "BJwx+sAC6jreaV45"
check_db noxify noxify 'cZskyJqqE7?7V_8=#Ed^'
check_db venus venus "K6Yr4RV6jsBCjae4"
check_db gemini gemini 'ufTP<=JGB^j;c8#'
echo "DONE"
