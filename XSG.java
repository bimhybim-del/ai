import java.sql.*;
class XSG {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    // Read disbursement log with request headers
    System.out.println("---DISB-LOG-WITH-HEADERS---");
    ResultSet r = s.executeQuery("SELECT id,hit_url,substring(request_header,1,500),api_key_alias FROM xendit_disbursement_log ORDER BY id DESC LIMIT 5");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|URL="+r.getString(2)+"|HEADER="+r.getString(3)+"|ALIAS="+r.getString(4));
    // Also get unique api_key_alias values
    System.out.println("---UNIQUE-ALIASES---");
    r = s.executeQuery("SELECT DISTINCT api_key_alias FROM xendit_disbursement_log WHERE api_key_alias IS NOT NULL LIMIT 20");
    while(r.next()) System.out.println("ALIAS="+r.getString(1));
    // Link payment logs
    System.out.println("---LINK-PAY-LOG-COLS---");
    r = s.executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='xendit_link_payment_log'");
    while(r.next()) System.out.print(r.getString(1)+",");
    System.out.println();
    r = s.executeQuery("SELECT id,substring(request_header,1,500) FROM xendit_link_payment_log WHERE request_header LIKE '%xnd_%' ORDER BY id DESC LIMIT 3");
    while(r.next()) System.out.println("LPLOG ID="+r.getString(1)+"|HEADER="+r.getString(2));
    c.close();
  }
}
