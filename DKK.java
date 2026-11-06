import com.jcraft.jsch.*;
import java.io.*;
class DKK {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'echo ---SENTRY-CREATE-TOKEN---;docker exec sentry-self-hosted-web-1 sentry createuser --email admin@cpssoft.com --password kutul0nc4t --superuser --no-input 2>&1 | tail -3;echo ---SENTRY-AUTH---;curl -s -X POST -H \"Content-Type: application/json\" -d \"{\\\"username\\\":\\\"admin@cpssoft.com\\\",\\\"password\\\":\\\"kutul0nc4t\\\"}\" http://localhost:9000/api/0/auth/ 2>/dev/null | head -5;echo ---SENTRY-ORG---;curl -s -u admin@cpssoft.com:kutul0nc4t http://localhost:9000/api/0/organizations/ 2>/dev/null | python3 -c \"import sys,json;[print(o.get(\\\"slug\\\")) for o in json.load(sys.stdin)]\" 2>&1 | head -5' 2>&1 | head -20");
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
