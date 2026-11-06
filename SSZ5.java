import com.jcraft.jsch.*;
import java.io.*;
class SSZ5 {
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
    ch.setCommand("host olivetin.internaltools.biz 2>/dev/null;host artifacts.internaltools.biz 2>/dev/null;host gitlab1.internaltools.biz 2>/dev/null;echo ---OLIVETIN---;curl -sk --max-time 5 https://olivetin.internaltools.biz/ 2>/dev/null | head -20;echo ---HARBOR---;curl -sk --max-time 5 https://artifacts.internaltools.biz/api/v2.0/health 2>/dev/null | head -10;echo ---GITLAB---;curl -sk --max-time 5 https://gitlab1.internaltools.biz/api/v4/projects 2>/dev/null | head -10");
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
