import com.jcraft.jsch.*;
import java.io.*;
class DKD {
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
    // showmount from host, mount from host if nfs-common installed
    ch.setCommand("echo kutul0nc4t | sudo -S showmount -e 10.14.16.20 2>&1;echo ---MOUNT---;echo kutul0nc4t | sudo -S mkdir -p /tmp/nfs_mount 2>/dev/null;echo kutul0nc4t | sudo -S mount -t nfs -o ro,nolock 10.14.16.20:/mnt/tmp/temp_1/export /tmp/nfs_mount 2>&1;echo ---LIST---;echo kutul0nc4t | sudo -S ls /tmp/nfs_mount/ 2>/dev/null;echo ---NEO---;echo kutul0nc4t | sudo -S find /tmp/nfs_mount/neo/ -type f 2>/dev/null | head -20;echo ---ACCURATE---;echo kutul0nc4t | sudo -S find /tmp/nfs_mount/accurate/ -maxdepth 2 -name '*.properties' -o -name '*.yml' -o -name '*.yaml' -o -name '*.xml' -o -name '*.env' 2>/dev/null | head -10");
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
