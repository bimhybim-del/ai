import java.sql.*;
class XSD {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/noxify","noxify","cZskyJqqE7?7V_8=#Ed^");
    Statement s = c.createStatement();
    System.out.println("---XENDIT-LOGS---");
    ResultSet r = s.executeQuery("SELECT id,url,substring(payload,1,500),substring(response,1,300),keywords1 FROM payment_integration_log WHERE url LIKE '%xendit%' OR payload LIKE '%xnd_%' OR keywords1 LIKE '%xendit%' ORDER BY id DESC LIMIT 5");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|URL="+r.getString(2)+"|PAYLOAD="+r.getString(3)+"|RESP="+r.getString(4)+"|KW="+r.getString(5));
    // Also search for Xendit in online_payment_history
    System.out.println("---ONLINE-PAYMENT-XENDIT---");
    r = s.executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='online_payment_history'");
    while(r.next()) System.out.print(r.getString(1)+",");
    System.out.println();
    // Search pos_payment_qris
    System.out.println("---POS-QRIS---");
    r = s.executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='pos_payment_qris'");
    while(r.next()) System.out.print(r.getString(1)+",");
    System.out.println();
    r = s.executeQuery("SELECT * FROM pos_payment_qris LIMIT 2");
    ResultSetMetaData md = r.getMetaData();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v=r.getString(i);
        if(v!=null&&v.length()>0) System.out.print(md.getColumnName(i)+"="+v.substring(0,Math.min(100,v.length()))+"|");
      }
      System.out.println();
    }
    c.close();
  }
}
