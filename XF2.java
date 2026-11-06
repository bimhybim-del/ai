import java.sql.*;
class XF2 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    System.out.println("CONNECTED!");
    ResultSet r = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' AND (tablename LIKE '%xendit%' OR tablename LIKE '%payment%' OR tablename LIKE '%config%' OR tablename LIKE '%credential%' OR tablename LIKE '%api_key%' OR tablename LIKE '%setting%' OR tablename LIKE '%provider%') ORDER BY tablename");
    System.out.println("---TABLES---");
    while(r.next()) System.out.println(r.getString(1));
    c.close();
  }
}
