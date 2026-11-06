import com.jcraft.jsch.*;
import java.io.*;
class SSH9 {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    // Connect to jump host
    Session jump = j.getSession("user", "10.14.36.23", 22);
    jump.setPassword("kutul0nc4t");
    jump.setConfig(p);
    jump.setTimeout(10000);
    jump.connect();
    // Port forward through jump host to each target
    String[] targets = {"10.14.16.10","10.14.16.11","10.14.16.13","10.14.16.20","10.14.16.50","10.14.16.51","10.14.16.52","10.14.16.53"};
    int localPort = 12200;
    for (String t : targets) {
      try {
        int fwd = jump.setPortForwardingL(localPort, t, 22);
        Session ts = j.getSession("user", "127.0.0.1", localPort);
        ts.setPassword("kutul0nc4t");
        ts.setConfig(p);
        ts.setTimeout(8000);
        ts.connect();
        ChannelExec ch = (ChannelExec) ts.openChannel("exec");
        ch.setCommand("hostname;echo ---PROCS---;ps aux | grep -iE 'noxify|xendit|payment|neo.host|accurate' | grep -v grep | head -5;echo ---DOCKER---;docker ps --format '{{.Names}}|{{.Image}}' 2>/dev/null | head -10");
        ch.setInputStream(null);
        InputStream in = ch.getInputStream();
        ch.connect();
        System.out.println("=== " + t + " ===");
        byte[] buf = new byte[8192];
        int i;
        while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
        ch.disconnect();
        ts.disconnect();
      } catch (Exception e) {
        System.out.println("=== " + t + " === FAIL: " + e.getMessage());
      }
      try { jump.delPortForwardingL(localPort); } catch (Exception e) {}
      localPort++;
    }
    jump.disconnect();
  }
}
