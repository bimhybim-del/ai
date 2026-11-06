import javax.management.*;
import javax.management.remote.*;
import java.util.*;
class JX2 {
  public static void main(String[] a) throws Exception {
    JMXServiceURL u = new JMXServiceURL("service:jmx:rmi:///jndi/rmi://localhost:9005/jmxrmi");
    JMXConnector c = JMXConnectorFactory.connect(u);
    MBeanServerConnection m = c.getMBeanServerConnection();
    System.out.println("---ALL-DOMAINS---");
    for(String d : m.getDomains()) System.out.println(d);
    System.out.println("---DATASOURCE-BEANS---");
    Set<ObjectName> beans = m.queryNames(null, null);
    for(ObjectName b : beans) {
      String n = b.toString().toLowerCase();
      if(n.contains("datasource") || n.contains("dbcp") || n.contains("hikari") || n.contains("c3p0") || n.contains("pool") || n.contains("jdbc") || n.contains("globalresource")) {
        System.out.println("BEAN: " + b);
        MBeanInfo info = m.getMBeanInfo(b);
        for(MBeanAttributeInfo attr : info.getAttributes()) {
          try {
            Object v = m.getAttribute(b, attr.getName());
            if(v != null) System.out.println("  " + attr.getName() + " = " + v.toString().substring(0, Math.min(300, v.toString().length())));
          } catch(Exception e) {}
        }
      }
    }
    // Also look for Spring context beans
    System.out.println("---SPRING-BEANS---");
    for(ObjectName b : beans) {
      String n = b.toString().toLowerCase();
      if(n.contains("spring") || n.contains("context") || n.contains("environment")) {
        System.out.println("BEAN: " + b);
      }
    }
    c.close();
  }
}
