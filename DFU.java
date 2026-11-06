import java.sql.*;
class DFU {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    // Noxify payment_integration_log - outbound API calls to xendit
    System.out.println("===NOXIFY PAYMENT_INTEGRATION_LOG===");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/noxify","noxify","cZskyJqqE7?7V_8=#Ed^");
    Statement s = c.createStatement();
    ResultSet r = s.executeQuery("SELECT id,url,substring(payload,1,400) FROM payment_integration_log WHERE url LIKE '%api.xendit%' ORDER BY id DESC LIMIT 3");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|URL="+r.getString(2)+"|PAYLOAD="+r.getString(3));
    // Search for ANY entry with xnd_ in payload
    System.out.println("---PAYLOAD-XND---");
    r = s.executeQuery("SELECT id,url,substring(payload,1,300) FROM payment_integration_log WHERE payload LIKE '%xnd_%' ORDER BY id DESC LIMIT 3");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|URL="+r.getString(2)+"|P="+r.getString(3));
    // NEO xendit_disbursement_log with request_body
    System.out.println("===NEO DISBURSEMENT LOG===");
    Connection c2 = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    r = c2.createStatement().executeQuery("SELECT id,hit_url,substring(request_body,1,300),api_key_alias FROM xendit_disbursement_log WHERE request_body IS NOT NULL ORDER BY id DESC LIMIT 3");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|URL="+r.getString(2)+"|BODY="+r.getString(3)+"|ALIAS="+r.getString(4));
    // Also check xendit_link_payment_callback_log
    System.out.println("===CALLBACK LOG===");
    r = c2.createStatement().executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='xendit_link_payment_callback_log'");
    while(r.next()) System.out.print(r.getString(1)+",");
    System.out.println();
    r = c2.createStatement().executeQuery("SELECT id,substring(payload,1,300) FROM xendit_link_payment_callback_log WHERE payload LIKE '%xnd_%' ORDER BY id DESC LIMIT 2");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|P="+r.getString(2));
    c.close();
    c2.close();
  }
}
