import java.sql.*;
class FD3 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/noxify","noxify","cZskyJqqE7?7V_8=#Ed^");
    Statement s = c.createStatement();
    System.out.println("---SSH-HOST---");
    ResultSet r = s.executeQuery("SELECT * FROM ssh_host");
    ResultSetMetaData md = r.getMetaData();
    for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
    System.out.println();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v=r.getString(i);
        System.out.print((v!=null?v.substring(0,Math.min(200,v.length())):"null")+"|");
      }
      System.out.println();
    }
    System.out.println("---SSH-HOST-VARIABLE---");
    r = s.executeQuery("SELECT * FROM ssh_host_variable");
    md = r.getMetaData();
    for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
    System.out.println();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v=r.getString(i);
        System.out.print((v!=null?v.substring(0,Math.min(200,v.length())):"null")+"|");
      }
      System.out.println();
    }
    System.out.println("---BCA-VA-OAUTH---");
    r = s.executeQuery("SELECT * FROM bca_va_oauth ORDER BY id DESC LIMIT 3");
    md = r.getMetaData();
    for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
    System.out.println();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v=r.getString(i);
        System.out.print((v!=null?v.substring(0,Math.min(150,v.length())):"null")+"|");
      }
      System.out.println();
    }
    c.close();
  }
}
