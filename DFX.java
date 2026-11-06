import java.sql.*;
class DFX {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    System.out.println("---PUBLIC-KEY-NOT-NULL---");
    ResultSet r = c.createStatement().executeQuery("SELECT id,type,api_key,public_key,merchant_name FROM e_payment_register WHERE public_key IS NOT NULL AND public_key != '' LIMIT 10");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|TYPE="+r.getString(2)+"|KEY="+r.getString(3).substring(0,Math.min(40,r.getString(3).length()))+"...|PUBKEY="+r.getString(4).substring(0,Math.min(100,r.getString(4).length()))+"|MERCH="+r.getString(5));
    System.out.println("---CLIENT-ID-NOT-NULL---");
    r = c.createStatement().executeQuery("SELECT id,type,client_id,client_secret,merchant_name FROM e_payment_register WHERE client_id IS NOT NULL AND type LIKE '%XENDIT%' LIMIT 5");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|TYPE="+r.getString(2)+"|CID="+r.getString(3)+"|CSEC="+r.getString(4)+"|MERCH="+r.getString(5));
    // Check ALL types with client_id/client_secret populated
    System.out.println("---ALL-WITH-CLIENT-CREDS---");
    r = c.createStatement().executeQuery("SELECT DISTINCT type FROM e_payment_register WHERE client_id IS NOT NULL");
    while(r.next()) System.out.println("TYPE="+r.getString(1));
    // Check PAPER disbursement keys (might be interesting)
    System.out.println("---PAPER-DISBURSEMENT---");
    r = c.createStatement().executeQuery("SELECT id,api_key,client_id,client_secret,merchant_name FROM e_payment_register WHERE type='PAPER_DISBURSEMENT' AND deleted='f' LIMIT 5");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|KEY="+r.getString(2)+"|CID="+r.getString(3)+"|CSEC="+r.getString(4)+"|MERCH="+r.getString(5));
    c.close();
  }
}
