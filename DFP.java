import java.sql.*;
class DFP {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/venus","venus","K6Yr4RV6jsBCjae4");
    Statement s = c.createStatement();
    // Search ALL text columns in ALL Venus tables for xnd_
    System.out.println("---VENUS-XND-SEARCH---");
    ResultSet tables = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename");
    java.util.List<String> tlist = new java.util.ArrayList<>();
    while(tables.next()) tlist.add(tables.getString(1));
    for(String t : tlist) {
      try {
        ResultSet cols = c.createStatement().executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='"+t+"' AND data_type IN ('character varying','text') LIMIT 10");
        while(cols.next()) {
          String col = cols.getString(1);
          try {
            ResultSet r = c.createStatement().executeQuery("SELECT \""+col+"\" FROM \""+t+"\" WHERE \""+col+"\" LIKE '%xnd_%' LIMIT 1");
            if(r.next()) System.out.println("FOUND: "+t+"."+col+" = "+r.getString(1).substring(0,Math.min(200,r.getString(1).length())));
          } catch(Exception e) {}
        }
      } catch(Exception e) {}
    }
    // Also dump billing_payment sample
    System.out.println("---BILLING-PAYMENT-SAMPLE---");
    ResultSet r = s.executeQuery("SELECT * FROM billing_payment ORDER BY id DESC LIMIT 2");
    ResultSetMetaData md = r.getMetaData();
    for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
    System.out.println();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v=r.getString(i);
        System.out.print((v!=null?v.substring(0,Math.min(100,v.length())):"null")+"|");
      }
      System.out.println();
    }
    c.close();
  }
}
