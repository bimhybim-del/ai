import com.jcraft.jsch.*;
import java.io.*;
class DKR {
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
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'echo ---ADD-TO-ORG---;docker exec sentry-self-hosted-web-1 sentry django shell -c \"from django.contrib.auth import get_user_model;from sentry.models.organization import Organization;from sentry.models.organizationmember import OrganizationMember;U=get_user_model();u=U.objects.get(email=\\\"admin@cpssoft.com\\\");o=Organization.objects.first();m,c=OrganizationMember.objects.get_or_create(user_id=u.id,organization=o,defaults={\\\"role\\\":\\\"owner\\\"});print(\\\"ORG:\\\"+o.slug+\\\" MEMBER:\\\"+str(m.id)+\\\" CREATED:\\\"+str(c))\" 2>&1 | grep -E \"ORG:|Error\" | head -3;echo ---PROJECTS---;curl -s -H \"Authorization: Bearer " + token + "\" http://localhost:9000/api/0/organizations/sentry/projects/ 2>/dev/null | python3 -c \"import sys,json;[print(p[\\\"slug\\\"],p.get(\\\"name\\\")) for p in json.load(sys.stdin)]\" 2>&1 | head -20' 2>&1");
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
