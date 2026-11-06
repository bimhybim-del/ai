import com.jcraft.jsch.*;
import java.io.*;
class XMC {
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
    // jcmd to dump VM system properties - will show decrypted DB password
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.186 \"echo kutul0nc4t | sudo -S -u nox-tmct /usr/lib/jvm/java-1.8.0-amazon-corretto/bin/jcmd 711681 VM.system_properties 2>&1 | grep -iE \\\"db\\\\.\\\\|pass\\\\|xendit\\\\|xnd_\\\\|jdbc\\\\|url\\\\|datasource\\\" | head -20\" 2>&1' 2>&1");
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
