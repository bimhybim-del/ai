import com.jcraft.jsch.*;
import java.io.*;
class DKW {
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
    // Find Sentry's postgres container and query it
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'echo ---PG-CONTAINER---;docker ps --filter name=postgres --format \"{{.Names}}\" 2>/dev/null;echo ---SEARCH-ENV---;docker exec sentry-self-hosted-web-1 sentry django shell -c \"from sentry.models.project import Project;p=Project.objects.get(slug=\\\"prd4-neo\\\");from sentry.models.options.project_option import ProjectOption;opts=ProjectOption.objects.filter(project=p);[print(o.key,o.value) for o in opts]\" 2>&1 | head -20;echo ---SEARCH-NODESTORE---;docker exec sentry-self-hosted-web-1 sentry django shell -c \"from sentry.nodestore.django.backend import DjangoNodeStorage;ns=DjangoNodeStorage();from sentry.models.project import Project;p=Project.objects.get(slug=\\\"prd4-neo\\\");print(\\\"NEO_PROJECT_ID:\\\",p.id)\" 2>&1 | head -5' 2>&1");
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
