import java.sql.*;
class XF9 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    // Search ALL tables for xnd_production pattern
    System.out.println("---SEARCH-ALL-TABLES---");
    ResultSet tables = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename");
    java.util.List<String> tlist = new java.util.ArrayList<>();
    while(tables.next()) tlist.add(tables.getString(1));
    for(String t : tlist) {
      try {
        Statement s2 = c.createStatement();
        ResultSet r = s2.executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='"+t+"' AND data_type IN ('character varying','text') LIMIT 20");
        while(r.next()) {
          String col = r.getString(1);
          try {
            Statement s3 = c.createStatement();
            ResultSet r2 = s3.executeQuery("SELECT "+col+" FROM "+t+" WHERE "+col+" LIKE '%xnd_production%' LIMIT 1");
            if(r2.next()) {
              String val = r2.getString(1);
              System.out.println("FOUND! TABLE="+t+" COL="+col+" VAL="+val.substring(0,Math.min(200,val.length())));
            }
          } catch(Exception e) {}
        }
      } catch(Exception e) {}
    }
    c.close();
  }
}
