import com.jcraft.jsch.*;
import java.io.*;
class SSH4 {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    Session s = j.getSession("user", "10.14.36.23", 22);
    s.setPassword("kutul0nc4t");
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    s.setConfig(p);
    s.setTimeout(15000);
    s.connect();
    ChannelExec ch = (ChannelExec) s.openChannel("exec");
    // Scan for payment/noxify servers and try SSH with kutul0nc4t
    ch.setCommand("echo ---RESOLVE---;getent hosts payment.accurate.id 2>/dev/null || host payment.accurate.id 2>/dev/null || dig +short payment.accurate.id 2>/dev/null;echo ---ROUTE---;ip route show 2>/dev/null | head -10;echo ---ARP---;arp -a 2>/dev/null | head -20;echo ---DNS---;cat /etc/resolv.conf;echo ---HOSTS---;cat /etc/hosts | head -30;echo ---DOCKER-NETWORKS---;docker network ls 2>/dev/null;echo ---SCAN-10.14---;for i in $(seq 1 50); do timeout 1 bash -c \"echo > /dev/tcp/10.14.36.$i/22\" 2>/dev/null && echo 10.14.36.$i:22-OPEN; done;echo ---SCAN-10.13---;for i in 10 11 12 13 14 15 16 17 18 19 20; do timeout 1 bash -c \"echo > /dev/tcp/10.13.16.$i/22\" 2>/dev/null && echo 10.13.16.$i:22-OPEN; done");
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
