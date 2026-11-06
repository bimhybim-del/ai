import java.sql.*;
class XSJ {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    // Count ALL production keys (not development)
    System.out.println("---TOTAL-PROD-KEYS---");
    ResultSet r = s.executeQuery("SELECT type,count(*) FROM e_payment_register WHERE api_key LIKE 'xnd_production%' AND deleted='f' GROUP BY type ORDER BY type");
    while(r.next()) System.out.println(r.getString(1)+"|prod_count="+r.getString(2));
    // Get Xendit Link Payment production keys (the 2702 set minus dev keys)
    System.out.println("---LINK-PAYMENT-PROD-COUNT---");
    r = s.executeQuery("SELECT count(*) FROM e_payment_register WHERE type='XENDIT_LINK_PAYMENT' AND api_key LIKE 'xnd_production%' AND deleted='f'");
    r.next();
    System.out.println("LINK_PAYMENT_PROD="+r.getString(1));
    // Get disbursement prod keys with balance check capability
    System.out.println("---DISBURSEMENT-PROD-KEYS---");
    r = s.executeQuery("SELECT api_key,merchant_name FROM e_payment_register WHERE type='XENDIT_DISBURSEMENT' AND api_key LIKE 'xnd_production%' AND deleted='f'");
    while(r.next()) System.out.println(r.getString(1)+"|"+r.getString(2));
    c.close();
  }
}
