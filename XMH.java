import java.sql.*;
class XMH {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/noxify","noxify","cZskyJqqE7?7V_8=#Ed^");
    Statement s = c.createStatement();
    ResultSet r = s.executeQuery("SELECT * FROM config");
    ResultSetMetaData md = r.getMetaData();
    int cols = md.getColumnCount();
    for(int i=1;i<=cols;i++) System.out.print(md.getColumnName(i)+"|");
    System.out.println();
    while(r.next()) {
      for(int i=1;i<=cols;i++) {
        String v = r.getString(i);
        System.out.print((v!=null?v.substring(0,Math.min(300,v.length())):"null")+"|");
      }
      System.out.println();
    }
    c.close();
  }
}
