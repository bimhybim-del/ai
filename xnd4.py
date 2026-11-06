import psycopg2
c=psycopg2.connect(host="sentry-self-hosted-postgres-1",dbname="postgres",user="postgres")
cur=c.cursor()

# Check if data scrubbing removes API keys
cur.execute("SELECT key,value FROM sentry_projectoptions WHERE project_id=11 AND key LIKE '%scrub%' OR key LIKE '%security%' OR key LIKE '%pii%'")
print("---SCRUB-CONFIG---")
for r in cur.fetchall():
    print(r[0], r[1][:200] if r[1] else None)

# Search sentry_message for xendit errors with env context
cur.execute("""SELECT message FROM sentry_message 
WHERE message LIKE '%xendit%' OR message LIKE '%Xendit%' 
ORDER BY id DESC LIMIT 5""")
print("---MESSAGES---")
for r in cur.fetchall():
    print(r[0][:300])

# Check environment/context data in groupedmessage
cur.execute("""SELECT data FROM sentry_groupedmessage 
WHERE message LIKE '%xendit%' 
ORDER BY id DESC LIMIT 3""")
print("---GROUP-DATA---") 
for r in cur.fetchall():
    raw = r[0].tobytes() if hasattr(r[0],"tobytes") else r[0]
    print(str(raw)[:500])

c.close()
