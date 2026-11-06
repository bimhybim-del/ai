import psycopg2
c=psycopg2.connect(host="sentry-self-hosted-postgres-1",dbname="postgres",user="postgres")
cur=c.cursor()
cur.execute("SELECT tablename FROM pg_tables WHERE schemaname='public' AND (tablename LIKE '%event%' OR tablename LIKE '%group%' OR tablename LIKE '%message%' OR tablename LIKE '%issue%') ORDER BY tablename")
print("---TABLES---")
for r in cur.fetchall():
    print(r[0])

# Also directly search via Sentry API for breadcrumbs/request data containing xnd_
print("---SEARCH-ALL-TABLES---")
cur.execute("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename")
for r in cur.fetchall():
    try:
        cur2=c.cursor()
        cur2.execute(f"SELECT count(*) FROM {r[0]}")
        cnt=cur2.fetchone()[0]
        if cnt > 0:
            print(f"{r[0]}: {cnt} rows")
    except:
        c.rollback()
c.close()
