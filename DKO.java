import com.jcraft.jsch.*;
import java.io.*;
class DKO {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'docker exec sentry-self-hosted-web-1 sentry django shell -c \"from sentry.models.apitoken import ApiToken;from sentry.models.user import User;u=User.objects.get(email=\\\"admin@cpssoft.com\\\");t=ApiToken.objects.create(user=u,scope_list=[\\\"project:read\\\",\\\"event:read\\\",\\\"org:read\\\"]);print(\\\"TOKEN:\\\"+t.token)\" 2>&1 | tail -3' 2>&1");
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
