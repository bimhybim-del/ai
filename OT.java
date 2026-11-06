import com.jcraft.jsch.*;
import java.io.*;
class OT {
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
    ch.setCommand("echo ---OLIVETIN-DOCKER---;docker ps --format '{{.Names}}|{{.Image}}|{{.Ports}}' 2>/dev/null | grep -i olive;echo ---ALL-CONTAINERS---;docker ps -a --format '{{.Names}}|{{.Image}}' 2>/dev/null;echo ---OLIVETIN-CONFIG---;docker exec $(docker ps -q --filter name=olive 2>/dev/null | head -1) cat /config/config.yaml 2>/dev/null | head -50;echo ---OLIVETIN-ENV---;docker exec $(docker ps -q --filter name=olive 2>/dev/null | head -1) env 2>/dev/null | grep -iE 'TOKEN|KEY|SECRET|PASS' | head -10");
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
