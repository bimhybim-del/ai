import com.jcraft.jsch.*;
import java.io.*;
class DKNEO3 {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session jump = j.getSession("user", "10.14.36.23", 22);
    jump.setPassword("kutul0nc4t");
    jump.setConfig(p);
    jump.setTimeout(10000);
    jump.connect();
    ChannelExec ch = (ChannelExec) jump.openChannel("exec");
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 \"echo ---CONFIG-FILES---;find /progs/neo/ -maxdepth 5 -name \\\"*.properties\\\" -o -name \\\"*.yml\\\" -o -name \\\"*.yaml\\\" -o -name \\\"*.xml\\\" -o -name \\\"*.env\\\" -o -name \\\"*.json\\\" 2>/dev/null | grep -v WEB-INF/classes | head -20;echo ---GREP-XENDIT---;grep -r \\\"xnd_\\\" /progs/neo/ --include=\\\"*.properties\\\" --include=\\\"*.yml\\\" --include=\\\"*.yaml\\\" --include=\\\"*.xml\\\" --include=\\\"*.env\\\" --include=\\\"*.json\\\" 2>/dev/null | head -10\" 2>&1' 2>&1 | head -40");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    jump.disconnect();
  }
}
