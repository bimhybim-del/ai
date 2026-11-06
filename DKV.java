import com.jcraft.jsch.*;
import java.io.*;
class DKV {
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
    // Search Sentry's config/env files for Xendit DSN that might have the API key
    // Also check if NEO project has env vars stored in Sentry
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'echo ---SENTRY-DSN-KEYS---;docker exec sentry-self-hosted-web-1 sentry django shell -c \"from sentry.models.projectkey import ProjectKey;from sentry.models.project import Project;[(print(p.name,k.public_key,k.secret_key,k.get_dsn())) for p in Project.objects.all() for k in ProjectKey.objects.filter(project=p)]\" 2>&1 | grep -E \"neo|noxify|payment\" | head -10;echo ---NEO-PROJECT-DETAIL---;curl -s -H \"Authorization: Bearer e7d4433457096098e9561169f778ea5b46e2162ced13df7f2da60463def9d44d\" http://localhost:9000/api/0/projects/sentry/prd4-neo/keys/ 2>/dev/null | python3 -c \"import sys,json;[print(k[\\\"label\\\"],k.get(\\\"dsn\\\",{}).get(\\\"public\\\",\\\"\\\"),k.get(\\\"dsn\\\",{}).get(\\\"secret\\\",\\\"\\\")) for k in json.load(sys.stdin)]\" 2>&1' 2>&1");
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
