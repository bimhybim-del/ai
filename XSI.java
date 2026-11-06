import java.sql.*;
class XSI {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    System.out.println("---ALL-XENDIT-DISBURSEMENT-KEYS---");
    ResultSet r = s.executeQuery("SELECT id,api_key,merchant_name,database_id,type,suspended,deleted FROM e_payment_register WHERE type='XENDIT_DISBURSEMENT' AND deleted='f' ORDER BY id");
    while(r.next()) {
      System.out.println(r.getString(1)+"|"+r.getString(2)+"|"+r.getString(3)+"|"+r.getString(4)+"|"+r.getString(5)+"|susp="+r.getString(6));
    }
    // Also get ALL unique types
    System.out.println("---ALL-TYPES---");
    r = s.executeQuery("SELECT type,count(*) FROM e_payment_register WHERE deleted='f' GROUP BY type ORDER BY type");
    while(r.next()) System.out.println(r.getString(1)+"|count="+r.getString(2));
    c.close();
  }
}
