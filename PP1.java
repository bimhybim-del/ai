import com.jcraft.jsch.*;
import java.io.*;
class PP1 {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session s1 = j.getSession("user", "10.14.36.23", 22);
    s1.setPassword("kutul0nc4t");
    s1.setConfig(p);
    s1.setTimeout(10000);
    s1.connect();
    int fwd1 = s1.setPortForwardingL(0, "10.13.16.117", 22);
    Session s2 = j.getSession("user", "127.0.0.1", fwd1);
    s2.setPassword("kutul0nc4t");
    s2.setConfig(p);
    s2.setTimeout(8000);
    s2.connect();
    ChannelExec ch = (ChannelExec) s2.openChannel("exec");
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 '" +
      "echo ---WARNA-INDONESIA---;curl -sv --max-time 5 -H \"client_id: 9ff4a14c3016ded8274d686a71c6666b\" -H \"client_secret: c8277ac098bb1ac99b90210269f71b90\" https://open-api.paper.id/partner 2>&1 | tail -10;" +
      "echo ---ANDAL---;curl -s --max-time 5 -H \"client_id: 23c8c723f60c6bf0ff7b808503a1f771\" -H \"client_secret: cb09b80da9aeefe8934cdb2b6659975f\" https://open-api.paper.id/partner 2>/dev/null | head -c 500;" +
      "echo;echo ---ANDAL-BALANCE---;curl -s --max-time 5 -H \"client_id: 23c8c723f60c6bf0ff7b808503a1f771\" -H \"client_secret: cb09b80da9aeefe8934cdb2b6659975f\" https://open-api.paper.id/payment/balance 2>/dev/null | head -c 500' 2>&1 | head -30");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[16384];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s2.disconnect();
    s1.disconnect();
  }
}
