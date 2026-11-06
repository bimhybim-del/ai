import java.sql.*;
class XST {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/accurate","accurate","BashShell%729#Acc5");
    System.out.println("ACCURATE DB CONNECTED!");
    Statement s = c.createStatement();
    ResultSet r = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' AND (tablename LIKE '%xendit%' OR tablename LIKE '%payment%' OR tablename LIKE '%application%' OR tablename LIKE '%integration%' OR tablename LIKE '%api_key%' OR tablename LIKE '%credential%' OR tablename LIKE '%config%') ORDER BY tablename");
    System.out.println("---TABLES---");
    while(r.next()) System.out.println(r.getString(1));
    c.close();
  }
}
