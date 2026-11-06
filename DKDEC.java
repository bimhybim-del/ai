import com.jcraft.jsch.*;
import java.io.*;
class DKDEC {
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
    // Use Java on NEO server with Jasypt library to decrypt
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 \"JASYPT_JAR=\\$(find /progs/neo/ -name \\\"jasypt*.jar\\\" | head -1);echo JASYPT=\\$JASYPT_JAR;cd /tmp;echo \\\"import org.jasypt.encryption.pbe.StandardPBEStringEncryptor;class D{public static void main(String[] a){StandardPBEStringEncryptor e=new StandardPBEStringEncryptor();e.setPassword(\\\\\\\"8cnZ8Uk@FSt-6h#5\\\\\\\");String[] vals={\\\\\\\"6wLwgpTF4vPaNAn3pm5tYZJvBxofaCmLz0t1w9szlEc=\\\\\\\",\\\\\\\"OEztzHVPxgPugXTYUL4caPlF4PcAVfcwkQ0YP/f3vMMlQlq8QIdgNnjoqwSsg0TnrCE6OW2kreA=\\\\\\\"};String[] names={\\\\\\\"db.pass\\\\\\\",\\\\\\\"aws.s3.secretKey\\\\\\\"};for(int i=0;i<vals.length;i++){try{System.out.println(names[i]+\\\\\\\"=\\\\\\\"+e.decrypt(vals[i]));}catch(Exception x){System.out.println(names[i]+\\\\\\\": ERR \\\\\\\"+x.getMessage());}}}}\\\" > D.java;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/javac -cp \\$JASYPT_JAR D.java 2>&1;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/java -cp \\$JASYPT_JAR:. D 2>&1\" 2>&1' 2>&1 | head -20");
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
