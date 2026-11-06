import com.jcraft.jsch.*;
import java.io.*;
class DKE {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session s = j.getSession("user", "10.14.36.23", 22);
    s.setPassword("kutul0nc4t");
    s.setConfig(p);
    s.setTimeout(10000);
    s.connect();
    ChannelExec ch = (ChannelExec) s.openChannel("exec");
    ch.setCommand("echo kutul0nc4t | sudo -S apt-get install -y nfs-common 2>&1 | tail -5;echo ---SHOWMOUNT---;echo kutul0nc4t | sudo -S showmount -e 10.14.16.20 2>&1;echo ---MOUNT---;echo kutul0nc4t | sudo -S mount -t nfs -o ro,nolock,vers=3 10.14.16.20:/mnt/tmp/temp_1/export /tmp/nfs_mount 2>&1;echo ---LS---;echo kutul0nc4t | sudo -S ls /tmp/nfs_mount/ 2>/dev/null");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[16384];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s.disconnect();
  }
}
