import com.jcraft.jsch.*;
import java.io.*;
class SSHH {
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
    ch.setCommand("grep -iE 'ssh|xendit|xnd_|noxify|payment|deploy|neo|ansible|10\\.14\\.16\\.(5|6)' ~/.bash_history | tail -40;echo ---ROOT-HIST---;echo kutul0nc4t | sudo -S grep -iE 'ssh|xendit|noxify|deploy|ansible|10\\.14\\.16\\.(5|6)' /root/.bash_history 2>/dev/null | tail -20");
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
