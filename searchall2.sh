#!/bin/bash
H="-h 10.13.17.248 -p 5501 -t"

search_db() {
  local db=$1 user=$2 pass=$3
  export PGPASSWORD="$pass"
  for tbl in $(psql $H -U $user -d $db -c "SELECT tablename FROM pg_tables WHERE schemaname='public'" 2>/dev/null | tr -d ' ' | grep -v '^$'); do
    for col in $(psql $H -U $user -d $db -c "SELECT column_name FROM information_schema.columns WHERE table_name='$tbl' AND data_type IN ('character varying','text')" 2>/dev/null | tr -d ' ' | grep -v '^$'); do
      cnt=$(psql $H -U $user -d $db -c "SELECT count(*) FROM \"$tbl\" WHERE \"$col\" LIKE '%xnd_production%'" 2>/dev/null | tr -d ' ' | grep -E '^[0-9]+$' | head -1)
      if [ "$cnt" != "0" ] && [ -n "$cnt" ]; then
        echo "FOUND: $db.$tbl.$col = $cnt rows"
        psql $H -U $user -d $db -c "SELECT substring(\"$col\",1,80) FROM \"$tbl\" WHERE \"$col\" LIKE '%xnd_production%' LIMIT 2" 2>/dev/null
      fi
    done
  done
  echo "DONE_DB: $db"
}

# Already checked: neo, noxify, venus, gemini
# Now check remaining 12 databases with all available credentials
search_db neptune neo "BJwx+sAC6jreaV45"
search_db mercury neo "BJwx+sAC6jreaV45"
search_db _accurate_mcp neo "BJwx+sAC6jreaV45"
search_db accurate_mcp neo "BJwx+sAC6jreaV45"
search_db acls neo "BJwx+sAC6jreaV45"
search_db chatwoot neo "BJwx+sAC6jreaV45"
search_db leo neo "BJwx+sAC6jreaV45"
search_db pisces neo "BJwx+sAC6jreaV45"
search_db taurus neo "BJwx+sAC6jreaV45"
search_db sermo neo "BJwx+sAC6jreaV45"
search_db repmgr neo "BJwx+sAC6jreaV45"

# Also check Nucleus DB (different server)
export PGPASSWORD="HyperLink%Nuc#Acc5"
HN="-h 10.14.17.218 -p 5502 -t"
for tbl in $(psql $HN -U nucleus -d nucleus -c "SELECT tablename FROM pg_tables WHERE schemaname='public'" 2>/dev/null | tr -d ' ' | grep -v '^$'); do
  for col in $(psql $HN -U nucleus -d nucleus -c "SELECT column_name FROM information_schema.columns WHERE table_name='$tbl' AND data_type IN ('character varying','text')" 2>/dev/null | tr -d ' ' | grep -v '^$'); do
    cnt=$(psql $HN -U nucleus -d nucleus -c "SELECT count(*) FROM \"$tbl\" WHERE \"$col\" LIKE '%xnd_production%'" 2>/dev/null | tr -d ' ' | grep -E '^[0-9]+$' | head -1)
    if [ "$cnt" != "0" ] && [ -n "$cnt" ]; then
      echo "FOUND: nucleus.$tbl.$col = $cnt rows"
      psql $HN -U nucleus -d nucleus -c "SELECT substring(\"$col\",1,80) FROM \"$tbl\" WHERE \"$col\" LIKE '%xnd_production%' LIMIT 2" 2>/dev/null
    fi
  done
done
echo "DONE_DB: nucleus"
echo "ALL_COMPLETE"
