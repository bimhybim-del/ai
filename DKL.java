import com.jcraft.jsch.*;
import java.io.*;
class DKL {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'echo ---CREATE-TOKEN---;TOKEN=$(docker exec sentry-self-hosted-web-1 sentry createtoken --user admin@cpssoft.com --scope project:read --scope event:read --scope org:read 2>/dev/null | tail -1);echo TOKEN=$TOKEN;echo ---ORGS---;curl -s -H \"Authorization: Bearer $TOKEN\" http://localhost:9000/api/0/organizations/ 2>/dev/null | python3 -c \"import sys,json;d=json.load(sys.stdin);print(type(d),d[:200] if isinstance(d,str) else d)\" 2>&1;echo ---PROJECTS---;curl -s -H \"Authorization: Bearer $TOKEN\" http://localhost:9000/api/0/projects/ 2>/dev/null | python3 -c \"import sys,json;[print(p[\\\"slug\\\"],p.get(\\\"name\\\")) for p in json.load(sys.stdin)]\" 2>&1 | head -20' 2>&1 | head -30");
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
