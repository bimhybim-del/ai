import java.sql.*;
class XSB {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/noxify","noxify","cZskyJqqE7?7V_8=#Ed^");
    System.out.println("=== NOXIFY DB ===");
    // List ALL tables first
    Statement st = c.createStatement();
    ResultSet r = st.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename");
    System.out.println("---TABLES---");
    java.util.List<String> tlist = new java.util.ArrayList<>();
    while(r.next()) { String t=r.getString(1); tlist.add(t); System.out.println(t); }
    // Search tables with text columns for xnd_
    System.out.println("---SEARCHING---");
    for(String t : tlist) {
      try {
        ResultSet cols = c.createStatement().executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='"+t+"' AND data_type IN ('character varying','text')");
        while(cols.next()) {
          String col = cols.getString(1);
          try {
            ResultSet r2 = c.createStatement().executeQuery("SELECT \""+col+"\" FROM \""+t+"\" WHERE \""+col+"\" LIKE '%xnd_%' LIMIT 2");
            while(r2.next()) {
              String v = r2.getString(1);
              if(v!=null) System.out.println("FOUND: "+t+"."+col+" = "+v.substring(0,Math.min(200,v.length())));
            }
          } catch(Exception e) {}
        }
      } catch(Exception e) {}
    }
    c.close();
  }
}
