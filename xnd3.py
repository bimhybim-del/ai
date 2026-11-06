import psycopg2,zlib,re
c=psycopg2.connect(host="sentry-self-hosted-postgres-1",dbname="postgres",user="postgres")
cur=c.cursor()
cur.execute("SELECT data FROM nodestore_node WHERE data::text LIKE %s LIMIT 3", ("%xnd_%",))
rows=cur.fetchall()
for i,row in enumerate(rows):
    raw=row[0].tobytes() if hasattr(row[0],"tobytes") else row[0]
    # Try both compressed and raw
    try:
        dec=zlib.decompress(raw)
    except:
        dec=raw if isinstance(raw,bytes) else raw.encode()
    # Find xnd_ in the decompressed data with surrounding context
    for m in re.finditer(rb"(.{0,50}xnd_.{0,100})",dec):
        print(f"ROW{i}: {m.group(0)}")
    # Also search in raw data
    for m in re.finditer(rb"(.{0,50}xnd_.{0,100})",raw if isinstance(raw,bytes) else raw.encode()):
        print(f"RAW{i}: {m.group(0)}")
c.close()
