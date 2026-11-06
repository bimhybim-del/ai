import java.sql.*;
class XF6 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    System.out.println("---E_PAYMENT_REGISTER---");
    ResultSet r = s.executeQuery("SELECT * FROM e_payment_register LIMIT 10");
    ResultSetMetaData md = r.getMetaData();
    int cols = md.getColumnCount();
    for(int i=1;i<=cols;i++) System.out.print(md.getColumnName(i)+"|");
    System.out.println();
    while(r.next()) {
      for(int i=1;i<=cols;i++) {
        String v = r.getString(i);
        System.out.print((v!=null?v.substring(0,Math.min(150,v.length())):"null")+"|");
      }
      System.out.println();
    }
    System.out.println("---ALL-TABLES-WITH-DATA---");
    r = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename");
    while(r.next()) {
      String t = r.getString(1);
      Statement s2 = c.createStatement();
      ResultSet r2 = s2.executeQuery("SELECT count(*) FROM "+t);
      r2.next();
      int cnt = r2.getInt(1);
      if(cnt > 0 && cnt < 1000) System.out.println(t+": "+cnt+" rows");
    }
    c.close();
  }
}
