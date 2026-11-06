import com.jcraft.jsch.*;
import java.io.*;
class DKBC {
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
    String token = "e7d4433457096098e9561169f778ea5b46e2162ced13df7f2da60463def9d44d";
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'curl -s -H \"Authorization: Bearer " + token + "\" \"http://localhost:9000/api/0/issues/10181/events/latest/\" 2>/dev/null | python3 -c \"import json,sys;d=json.load(sys.stdin);[print(json.dumps(e,indent=2)[:5000]) for e in d.get(\\\"entries\\\",[]) if e.get(\\\"type\\\")==\\\"breadcrumbs\\\"]\" 2>&1 | grep -iE \"xendit|api\\.xendit|authorization|Basic |header\" | head -20' 2>&1");
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
