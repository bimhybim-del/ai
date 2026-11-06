import psycopg2,zlib,re
c=psycopg2.connect(host="sentry-self-hosted-postgres-1",dbname="postgres",user="postgres")
cur=c.cursor()
pattern = "%xnd_%"
cur.execute("SELECT data FROM nodestore_node WHERE data::text LIKE %s LIMIT 10", (pattern,))
rows=cur.fetchall()
for row in rows:
    raw=row[0].tobytes() if hasattr(row[0],"tobytes") else row[0]
    try:
        dec=zlib.decompress(raw)
    except:
        dec=raw if isinstance(raw,bytes) else raw.encode()
    for m in re.findall(rb"xnd_[a-zA-Z0-9_]{10,100}",dec):
        print(m.decode())
c.close()
