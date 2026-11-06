import com.jcraft.jsch.*;
import java.io.*;
class DK4B {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session jump = j.getSession("user", "10.14.36.23", 22);
    jump.setPassword("kutul0nc4t");
    jump.setConfig(p);
    jump.setTimeout(10000);
    jump.connect();
    ChannelExec ch = (ChannelExec) jump.openChannel("exec");
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'docker exec sentry-self-hosted-web-1 python3 -c \"import psycopg2,zlib,re;c=psycopg2.connect(host=\\\"sentry-self-hosted-postgres-1\\\",dbname=\\\"postgres\\\",user=\\\"postgres\\\");cur=c.cursor();cur.execute(\\\"SELECT data FROM nodestore_node WHERE data::text LIKE \\$\\$%xnd_%\\$\\$ LIMIT 5\\\");rows=cur.fetchall();print(len(rows),\\\"rows\\\");[print(m) for row in rows for m in re.findall(b\\\"xnd_[a-zA-Z0-9_]{10,100}\\\",row[0].tobytes() if hasattr(row[0],\\\"tobytes\\\") else row[0].encode() if isinstance(row[0],str) else row[0])];c.close()\" 2>&1 | head -10' 2>&1");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    jump.disconnect();
  }
}
