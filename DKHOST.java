import com.jcraft.jsch.*;
import java.io.*;
class DKHOST {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session jump = j.getSession("user", "10.14.36.23", 22);
    jump.setPassword("kutul0nc4t");
    jump.setConfig(p);
    jump.setTimeout(10000);
    jump.connect();
    ChannelExec ch = (ChannelExec) jump.openChannel("exec");
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'echo ---IP---;ip -4 addr show | grep inet;echo ---ROUTES---;ip route | head -5;echo ---RESOLVE---;host neo.prd4.jkt.cpssoft 2>/dev/null;host tomcats-neo-2.prd4.jkt.cpssoft 2>/dev/null;echo ---SCAN-NEO---;for h in 10.13.16.50 10.13.16.51 10.13.16.52 10.13.16.53 10.13.17.10 10.13.17.50; do timeout 1 bash -c \"echo > /dev/tcp/$h/22\" 2>/dev/null && echo $h:22-OPEN; done' 2>&1");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    jump.disconnect();
  }
}
