import com.jcraft.jsch.*;
import java.io.*;
class DKX {
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
    // Query Sentry PG directly
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'docker exec sentry-self-hosted-postgres-1 psql -U postgres -d sentry -c \"SELECT substring(cast(data as text),1,500) FROM nodestore_node WHERE cast(data as text) LIKE \\$\\$%xnd_%\\$\\$ LIMIT 3\" 2>&1 | head -30' 2>&1");
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
