#!/bin/bash
export PGPASSWORD="HyperLink%Nuc#Acc5"
DB="-h 10.14.17.218 -p 5502 -U nucleus -d nucleus -t"

echo "=== ALL TOKENS FOR XENDIT APPS ==="
psql $DB -c "SELECT id,token_id,client,the_user,refresh_token,expiration FROM oauth_access_token WHERE client IN ('e9183e9a-bdcc-4b26-8a4f-8cbb0f56b71d','70bf05c1-3fb6-4964-844c-e0e2f9c7f7e7','b010e516-8e47-4b4d-ac6c-46cc88bc4465','32318b58-778b-40da-b5f6-f3be12b2256b') ORDER BY expiration DESC" 2>&1

echo "=== TOTAL TOKENS PER XENDIT APP ==="
psql $DB -c "SELECT client,count(*) FROM oauth_access_token WHERE client IN ('e9183e9a-bdcc-4b26-8a4f-8cbb0f56b71d','70bf05c1-3fb6-4964-844c-e0e2f9c7f7e7','b010e516-8e47-4b4d-ac6c-46cc88bc4465','32318b58-778b-40da-b5f6-f3be12b2256b') GROUP BY client" 2>&1

echo "=== CBS BILLING SYSTEM TOKENS (enable_api_token=true) ==="
psql $DB -c "SELECT id,token_id,client,the_user,expiration FROM oauth_access_token WHERE client='499fbacc-b57a-4b98-97d3-a720e97a30ce' ORDER BY expiration DESC LIMIT 5" 2>&1
