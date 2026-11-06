import com.jcraft.jsch.*;
import java.io.*;
class DKZ {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'docker exec sentry-self-hosted-postgres-1 psql -U postgres -c \"SELECT tablename FROM pg_tables WHERE schemaname=\\$\\$public\\$\\$ AND tablename LIKE \\$\\$%node%\\$\\$\" 2>&1;echo ---SEARCH---;docker exec sentry-self-hosted-postgres-1 psql -U postgres -c \"SELECT substring(cast(data as text) from \\$\\$xnd_[a-zA-Z0-9_]{10,80}\\$\\$) FROM nodestore_node WHERE cast(data as text) LIKE \\$\\$%xnd_%\\$\\$ LIMIT 5\" 2>&1 | head -20' 2>&1");
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
