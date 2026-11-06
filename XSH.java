import java.sql.*;
class XSH {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    // Read link_payment_log header_request
    System.out.println("---LINK-PAY-HEADERS---");
    ResultSet r = s.executeQuery("SELECT id,substring(header_request,1,500),api_key_alias FROM xendit_link_payment_log WHERE header_request IS NOT NULL ORDER BY id DESC LIMIT 3");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|HDR="+r.getString(2)+"|ALIAS="+r.getString(3));
    // Match disbursement aliases to API keys
    System.out.println("---ALIAS-TO-KEY-MATCH---");
    String[] aliases = {"KaIqlsVGohEvkFvJY54pkgeHl","FdcY2FxIQGunMj5n6zsks5NYI","5609UhRCI6uhDXJLz4GVu3kec","44HiwEikW62CF5ZiFhiyjM6dg","KOlcEX1f4oqliEPFRTeFrnTQT","DqMcTd4vcOLPeeHgXBVlxa03m","pT20GbpNGLOKiAbFc6wMYppOx"};
    for(String alias : aliases) {
      r = s.executeQuery("SELECT api_key,merchant_name,type FROM e_payment_register WHERE api_key_alias='"+alias+"' LIMIT 1");
      if(r.next()) System.out.println("ALIAS="+alias+"|KEY="+r.getString(1).substring(0,Math.min(60,r.getString(1).length()))+"...|MERCH="+r.getString(2)+"|TYPE="+r.getString(3));
      else System.out.println("ALIAS="+alias+"|NOT_IN_REGISTER");
    }
    // Check if there are keys NOT in e_payment_register
    System.out.println("---ORPHAN-ALIASES---");
    r = s.executeQuery("SELECT DISTINCT d.api_key_alias FROM xendit_disbursement_log d WHERE d.api_key_alias NOT IN (SELECT api_key_alias FROM e_payment_register WHERE api_key_alias IS NOT NULL) AND d.api_key_alias IS NOT NULL");
    while(r.next()) System.out.println("ORPHAN: "+r.getString(1));
    c.close();
  }
}
