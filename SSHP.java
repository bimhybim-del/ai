import com.jcraft.jsch.*;
import java.io.*;
class SSHP {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    Session s = j.getSession("user", "10.14.36.23", 22);
    s.setPassword("kutul0nc4t");
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    s.setConfig(p);
    s.setTimeout(10000);
    s.connect();
    ChannelExec ch = (ChannelExec) s.openChannel("exec");
    ch.setCommand("echo kutul0nc4t | sudo -S apt-get install -y sshpass 2>&1 | tail -3;echo ---TRY-SSH---;for h in 10.14.16.50 10.14.16.51 10.14.16.52 10.14.16.53; do echo === $h ===; sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 user@$h 'hostname;ps aux | grep -iE \"noxify|xendit|payment|java.*neo\" | grep -v grep | head -3' 2>&1 | head -10; done");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s.disconnect();
  }
}
