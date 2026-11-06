import java.sql.*;
class XSC {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/noxify","noxify","cZskyJqqE7?7V_8=#Ed^");
    Statement s = c.createStatement();
    // Check payment_integration_log for Xendit API calls
    System.out.println("---PAYMENT-LOG-COLUMNS---");
    ResultSet r = s.executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='payment_integration_log'");
    while(r.next()) System.out.println(r.getString(1));
    System.out.println("---PAYMENT-LOG-XENDIT---");
    r = s.executeQuery("SELECT * FROM payment_integration_log WHERE request_body LIKE '%xnd_%' OR response_body LIKE '%xnd_%' OR url LIKE '%xendit%' ORDER BY id DESC LIMIT 3");
    ResultSetMetaData md = r.getMetaData();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v = r.getString(i);
        if(v!=null && v.length()>0) System.out.print(md.getColumnName(i)+"="+v.substring(0,Math.min(200,v.length()))+"|");
      }
      System.out.println();
    }
    // Also check pos_payment_qris for platform keys
    System.out.println("---POS-QRIS-COLUMNS---");
    r = s.executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='pos_payment_qris'");
    while(r.next()) System.out.println(r.getString(1));
    c.close();
  }
}
