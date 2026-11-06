import java.sql.*;
class FD2 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/noxify","noxify","cZskyJqqE7?7V_8=#Ed^");
    Statement s = c.createStatement();
    System.out.println("---ALL-TABLES---");
    ResultSet r = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename");
    while(r.next()) System.out.println(r.getString(1));
    System.out.println("---ONLINE-PAYMENT---");
    r = s.executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='online_payment_history'");
    while(r.next()) System.out.print(r.getString(1)+",");
    System.out.println();
    r = s.executeQuery("SELECT id,external_id,type,status,amount FROM online_payment_history ORDER BY id DESC LIMIT 3");
    while(r.next()) System.out.println(r.getString(1)+"|"+r.getString(2)+"|"+r.getString(3)+"|"+r.getString(4)+"|"+r.getString(5));
    System.out.println("---POS-QRIS---");
    r = s.executeQuery("SELECT id,external_id,type,status,amount FROM pos_payment_qris ORDER BY id DESC LIMIT 3");
    while(r.next()) System.out.println(r.getString(1)+"|"+r.getString(2)+"|"+r.getString(3)+"|"+r.getString(4)+"|"+r.getString(5));
    c.close();
  }
}
