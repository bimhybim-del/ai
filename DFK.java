import java.sql.*;
class DFK {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/gemini","gemini","ufTP<=JGB^j;c8#");
    System.out.println("GEMINI DB CONNECTED!");
    Statement s = c.createStatement();
    System.out.println("---SETTING-TABLE---");
    ResultSet r = s.executeQuery("SELECT * FROM setting");
    ResultSetMetaData md = r.getMetaData();
    for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
    System.out.println();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v=r.getString(i);
        System.out.print((v!=null?v.substring(0,Math.min(300,v.length())):"null")+"|");
      }
      System.out.println();
    }
    // Also search ALL tables for xendit/xnd_
    System.out.println("---ALL-TABLES---");
    r = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename");
    while(r.next()) System.out.println(r.getString(1));
    c.close();
  }
}
