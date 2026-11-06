import java.sql.*;
class XF8 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    ResultSet r = s.executeQuery("SELECT id,api_key,merchant_name,database_id,type,suspended,deleted FROM e_payment_register WHERE api_key LIKE 'xnd_production%' AND deleted='f' ORDER BY id");
    int cnt=0;
    while(r.next()) {
      cnt++;
      System.out.println(r.getString(1)+"|"+r.getString(2)+"|"+r.getString(3)+"|"+r.getString(4)+"|"+r.getString(5)+"|susp="+r.getString(6));
    }
    System.out.println("TOTAL_PROD_KEYS: "+cnt);
    c.close();
  }
}
