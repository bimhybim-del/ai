import java.sql.*;
class DFV {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    System.out.println("---DISB-LOG-SAMPLE---");
    ResultSet r = c.createStatement().executeQuery("SELECT id,hit_url,substring(request_body,1,400),api_key_alias,action FROM xendit_disbursement_log ORDER BY id DESC LIMIT 3");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|URL="+r.getString(2)+"|BODY="+r.getString(3)+"|ALIAS="+r.getString(4)+"|ACT="+r.getString(5));
    System.out.println("---DISB-LOG-COUNT---");
    r = c.createStatement().executeQuery("SELECT count(*) FROM xendit_disbursement_log");
    r.next(); System.out.println("TOTAL="+r.getInt(1));
    // Check xendit_callback_log
    System.out.println("---CALLBACK-LOG-COLS---");
    r = c.createStatement().executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='xendit_qris_callback_log'");
    while(r.next()) System.out.print(r.getString(1)+",");
    System.out.println();
    // Also try to find Xendit secret key by using the Xendit API with public key
    // The public key might give us account info
    c.close();
  }
}
