#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

/usr/bin/sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 user@10.13.16.196 bash << 'REMOTECMD'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

MASTERPASS='8TFB9eVu5iupcFZ1CGtXwsG0tzZCZ5Mh7lrJ7bI5GIN0HChbp39OAHnpW4HzMWzh'

echo "=== TRY TENANT DB 10.13.17.70:5549 with master.resource.password ==="

# Try various users with master password
for user in neo accurate nucleus postgres admin; do
  echo "--- User: $user ---"
  PGPASSWORD="$MASTERPASS" timeout 5 psql -h 10.13.17.70 -p 5549 -U "$user" -c "SELECT current_database(), current_user" 2>&1 | head -5
done

echo "=== TRY ANOTHER TENANT SERVER 10.13.17.96:5564 ==="
for user in neo accurate nucleus postgres admin; do
  echo "--- User: $user ---"
  PGPASSWORD="$MASTERPASS" timeout 5 psql -h 10.13.17.96 -p 5564 -U "$user" -c "SELECT current_database(), current_user" 2>&1 | head -5
done

echo "=== ALSO TRY neo password on tenant server ==="
PGPASSWORD='BJwx+sAC6jreaV45' timeout 5 psql -h 10.13.17.96 -p 5564 -U neo -c "SELECT datname FROM pg_database WHERE datistemplate=false LIMIT 10" 2>&1

echo "=== TRY cpssoft user (common internal) ==="
PGPASSWORD="$MASTERPASS" timeout 5 psql -h 10.13.17.70 -p 5549 -U cpssoft -c "SELECT 1" 2>&1

echo "=== TRY pg_roles to see what users exist ==="
PGPASSWORD="$MASTERPASS" timeout 5 psql -h 10.13.17.70 -p 5549 -U postgres -c "SELECT rolname FROM pg_roles LIMIT 20" 2>&1

echo "=== DONE ==="
REMOTECMD
