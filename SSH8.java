import com.jcraft.jsch.*;
import java.io.*;
class SSH8 {
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
    // First hop to internaltools
    Session s1 = j.getSession("user", "10.14.36.23", 22);
    s1.setPassword("kutul0nc4t");
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    s1.setConfig(p);
    s1.setTimeout(10000);
    s1.connect();
    // Try SSH from internaltools to production hosts
    String[] targets = {"10.14.16.10","10.14.16.11","10.14.16.13","10.14.16.20","10.14.16.50","10.14.16.51","10.14.16.52","10.14.16.53"};
    for (String t : targets) {
      System.out.println("=== " + t + " ===");
      String r = exec(s1, "sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 user@" + t + " 'hostname;ps aux | grep -iE \"noxify|xendit|payment|neo|accurate\" | grep -v grep | head -3' 2>&1 | head -10");
      System.out.println(r);
    }
    s1.disconnect();
  }
}
