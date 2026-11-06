import com.jcraft.jsch.*;
import java.io.*;
class DKS {
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
    // Search neo project issues for xendit-related errors
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'echo ---NEO-ISSUES---;curl -s -H \"Authorization: Bearer " + token + "\" \"http://localhost:9000/api/0/projects/sentry/prd4-neo/issues/?query=xendit&limit=5\" 2>/dev/null | python3 -c \"import sys,json;[print(i[\\\"id\\\"],i[\\\"title\\\"][:100]) for i in json.load(sys.stdin)]\" 2>&1 | head -10;echo ---NEO-TAGS---;curl -s -H \"Authorization: Bearer " + token + "\" \"http://localhost:9000/api/0/projects/sentry/prd4-neo/tags/\" 2>/dev/null | python3 -c \"import sys,json;[print(t[\\\"key\\\"]) for t in json.load(sys.stdin)]\" 2>&1 | head -20;echo ---NEO-ENV-SEARCH---;curl -s -H \"Authorization: Bearer " + token + "\" \"http://localhost:9000/api/0/projects/sentry/prd4-neo/issues/?query=xnd_production&limit=5\" 2>/dev/null | python3 -c \"import sys,json;d=json.load(sys.stdin);print(len(d),\\\"issues\\\")\" 2>&1' 2>&1");
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
