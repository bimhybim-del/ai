import com.jcraft.jsch.*;
import java.io.*;
class DKH {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.14.16.10 'echo kutul0nc4t | sudo -S ls /tmp/nfs_prod/nucleus/ 2>/dev/null | tail -10;echo ---FILE-TYPES---;echo kutul0nc4t | sudo -S file /tmp/nfs_prod/nucleus/*.json /tmp/nfs_prod/nucleus/*.properties /tmp/nfs_prod/nucleus/*.yml /tmp/nfs_prod/nucleus/*.xml 2>/dev/null | head -5;echo ---HAMMER---;echo kutul0nc4t | sudo -S ls /tmp/nfs_prod/hammer/ 2>/dev/null;echo ---JUPITER---;echo kutul0nc4t | sudo -S ls /tmp/nfs_prod/jupiter/ 2>/dev/null;echo ---VENUS---;echo kutul0nc4t | sudo -S ls /tmp/nfs_prod/venus/ 2>/dev/null | head -10' 2>&1");
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
