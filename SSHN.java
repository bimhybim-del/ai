import com.jcraft.jsch.*;
import java.io.*;
class SSHN {
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
    ch.setCommand("hostname;echo ---NFS-EXPORTS---;echo kutul0nc4t | sudo -S cat /etc/exports 2>/dev/null;echo ---MOUNTS---;df -h 2>/dev/null | head -20;echo ---NFS-SHARED---;echo kutul0nc4t | sudo -S ls /mnt/nfs/ 2>/dev/null;echo kutul0nc4t | sudo -S find /mnt/ -maxdepth 3 -type d 2>/dev/null | head -30;echo ---NOXIFY-FILES---;echo kutul0nc4t | sudo -S find /mnt/ -path '*noxify*' -maxdepth 5 2>/dev/null | head -20");
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
