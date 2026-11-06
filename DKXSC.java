import com.jcraft.jsch.*;
import java.io.*;
class DKXSC {
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
    // Find Nucleus server and search for Xendit platform key there
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'echo ---NUCLEUS-HOSTS---;for i in 1 2 3 4; do host tomcats-nucleus-$i.prd4.jkt.cpssoft 2>/dev/null | grep \"has address\"; done;echo ---ACCURATE-HOSTS---;for i in 1 2 3 4; do host tomcats-accurate-$i.prd4.jkt.cpssoft 2>/dev/null | grep \"has address\"; done' 2>&1");
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
