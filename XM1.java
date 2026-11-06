import java.sql.*;
class XM1 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    // Search ALL text columns in ALL tables for xnd_ pattern (not just e_payment_register)
    System.out.println("---SEARCHING-ALL-TABLES---");
    ResultSet tables = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename");
    java.util.List<String> tlist = new java.util.ArrayList<>();
    while(tables.next()) tlist.add(tables.getString(1));
    for(String t : tlist) {
      try {
        ResultSet cols = c.createStatement().executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='"+t+"' AND data_type IN ('character varying','text')");
        while(cols.next()) {
          String col = cols.getString(1);
          try {
            ResultSet r = c.createStatement().executeQuery("SELECT \""+col+"\" FROM \""+t+"\" WHERE \""+col+"\" LIKE '%xnd_%' AND \""+col+"\" NOT IN (SELECT api_key FROM e_payment_register) LIMIT 3");
            while(r.next()) {
              String v = r.getString(1);
              System.out.println("TABLE="+t+" COL="+col+" VAL="+v.substring(0,Math.min(200,v.length())));
            }
          } catch(Exception e) {}
        }
      } catch(Exception e) {}
    }
    // Also check config.properties for xendit
    System.out.println("---CONFIG-PROPERTIES---");
    ResultSet r = s.executeQuery("SELECT * FROM e_payment_register WHERE type LIKE '%XENDIT%' AND api_key NOT LIKE 'xnd_production%' AND api_key NOT LIKE 'xnd_development%' LIMIT 5");
    ResultSetMetaData md = r.getMetaData();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"="+r.getString(i)+"|");
      System.out.println();
    }
    c.close();
  }
}
