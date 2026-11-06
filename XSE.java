import java.sql.*;
class XSE {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/noxify","noxify","cZskyJqqE7?7V_8=#Ed^");
    Statement s = c.createStatement();
    // Search for outbound calls TO xendit API (not callbacks FROM xendit)
    System.out.println("---OUTBOUND-XENDIT-CALLS---");
    ResultSet r = s.executeQuery("SELECT id,url,substring(payload,1,500) FROM payment_integration_log WHERE url LIKE '%api.xendit%' OR url LIKE '%xendit.co%' ORDER BY id DESC LIMIT 5");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|URL="+r.getString(2)+"|PAYLOAD="+r.getString(3));
    // Also search for any entry with 'Basic ' auth header in payload
    System.out.println("---BASIC-AUTH-LOGS---");
    r = s.executeQuery("SELECT id,url,substring(payload,1,300) FROM payment_integration_log WHERE payload LIKE '%Basic %' OR payload LIKE '%Authorization%' ORDER BY id DESC LIMIT 5");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|URL="+r.getString(2)+"|PAYLOAD="+r.getString(3));
    // Check NEO DB xendit_disbursement_log for keys
    Connection c2 = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    System.out.println("---DISB-LOG-COLUMNS---");
    r = c2.createStatement().executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='xendit_disbursement_log'");
    while(r.next()) System.out.print(r.getString(1)+",");
    System.out.println();
    System.out.println("---DISB-LOG-SAMPLE---");
    r = c2.createStatement().executeQuery("SELECT * FROM xendit_disbursement_log ORDER BY id DESC LIMIT 2");
    ResultSetMetaData md = r.getMetaData();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v=r.getString(i);
        if(v!=null&&v.length()>0) System.out.print(md.getColumnName(i)+"="+v.substring(0,Math.min(200,v.length()))+"|");
      }
      System.out.println();
    }
    c.close();
    c2.close();
  }
}
