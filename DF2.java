import java.sql.*;
class DF2 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    String[] dbs = {"accurate_mcp","_accurate_mcp","acls","gemini","leo","pisces","taurus","sermo","chatwoot"};
    for(String db : dbs) {
      System.out.println("==="+db+"===");
      try {
        Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/"+db,"neo","BJwx+sAC6jreaV45");
        Statement s = c.createStatement();
        ResultSet r = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' AND (tablename LIKE '%xendit%' OR tablename LIKE '%payment%' OR tablename LIKE '%key%' OR tablename LIKE '%secret%' OR tablename LIKE '%credential%' OR tablename LIKE '%config%' OR tablename LIKE '%setting%') ORDER BY tablename");
        boolean found = false;
        while(r.next()) { System.out.println("  "+r.getString(1)); found=true; }
        if(!found) {
          r = s.executeQuery("SELECT count(*) FROM pg_tables WHERE schemaname='public'");
          r.next();
          System.out.println("  ("+r.getInt(1)+" tables, none matching payment/xendit/config)");
        }
        c.close();
      } catch(Exception e) {
        // Try noxify creds
        try {
          Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/"+db,"noxify","cZskyJqqE7?7V_8=#Ed^");
          Statement s = c.createStatement();
          ResultSet r = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' AND (tablename LIKE '%xendit%' OR tablename LIKE '%payment%' OR tablename LIKE '%config%') ORDER BY tablename");
          while(r.next()) System.out.println("  [noxify] "+r.getString(1));
          c.close();
        } catch(Exception e2) { System.out.println("  FAIL (both creds)"); }
      }
    }
  }
}
