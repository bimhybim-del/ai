import com.jcraft.jsch.*;
import java.io.*;
class DK9 {
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
    ch.setCommand("for name in portainer rancher vault consul docker neo noxify nucleus payment accurate olivetin jenkins cicd deploy ansible awx tower grafana prometheus kibana sentry gitlab1 gitlab2 nexus sonar harbor registry minio; do r=$(host $name.internaltools.biz 2>/dev/null | grep 'has address'); [ -n \"$r\" ] && echo \"$r\"; r=$(host $name.prd5.jkt.cpssoft 2>/dev/null | grep 'has address\\|is an alias'); [ -n \"$r\" ] && echo \"$r\"; done");
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
