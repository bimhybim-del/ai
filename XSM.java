import com.jcraft.jsch.*;
import java.io.*;
class XSM {
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
    int fwd2 = s2.setPortForwardingL(0, "10.13.16.196", 22);
    Session s3 = j.getSession("user", "127.0.0.1", fwd2);
    s3.setPassword("kutul0nc4t");
    s3.setConfig(p);
    s3.setTimeout(8000);
    s3.connect();
    ChannelExec ch = (ChannelExec) s3.openChannel("exec");
    // Try SSH to Accurate servers and read their configs
    ch.setCommand("for h in 10.13.16.132 10.13.16.133 10.13.16.134; do echo === $h ===; timeout 1 bash -c \"echo > /dev/tcp/$h/22\" 2>/dev/null && echo SSH-OPEN || echo SSH-CLOSED; done;echo ---ACCURATE-HTTP---;curl -sk --max-time 3 http://10.13.16.132:8216/ 2>/dev/null | head -3;echo ---ACCURATE-ENV-SEARCH---;echo kutul0nc4t | sudo -S find /progs/ -maxdepth 2 -type d 2>/dev/null | head -10");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s3.disconnect();
    s2.disconnect();
    s1.disconnect();
  }
}
