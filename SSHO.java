import com.jcraft.jsch.*;
import java.io.*;
class SSHO {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session jump = j.getSession("user", "10.14.36.23", 22);
    jump.setPassword("kutul0nc4t");
    jump.setConfig(p);
    jump.setTimeout(10000);
    jump.connect();
    int fwd = jump.setPortForwardingL(0, "10.14.16.20", 22);
    Session ts = j.getSession("user", "127.0.0.1", fwd);
    ts.setPassword("kutul0nc4t");
    ts.setConfig(p);
    ts.setTimeout(8000);
    ts.connect();
    ChannelExec ch = (ChannelExec) ts.openChannel("exec");
    ch.setCommand("echo kutul0nc4t | sudo -S find /mnt/tmp/temp_1/export/noxify/ -maxdepth 4 -type f 2>/dev/null | head -40;echo ---GREP-XENDIT---;echo kutul0nc4t | sudo -S grep -r 'xnd_' /mnt/tmp/temp_1/export/noxify/ --include='*.properties' --include='*.xml' --include='*.conf' --include='*.yml' --include='*.yaml' --include='*.env' --include='*.json' 2>/dev/null | head -10;echo ---FULL-EXPORT---;echo kutul0nc4t | sudo -S ls -la /mnt/tmp/temp_1/export/ 2>/dev/null | head -20");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    ts.disconnect();
    jump.disconnect();
  }
}
