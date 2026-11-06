import java.sql.*;
class XSA {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    String[][] dbs = {
      {"noxify","noxify","cZskyJqqE7?7V_8=#Ed^"},
      {"venus","neo","BJwx+sAC6jreaV45"},
      {"neptune","neo","BJwx+sAC6jreaV45"},
      {"mercury","neo","BJwx+sAC6jreaV45"},
      {"neo","neo","BJwx+sAC6jreaV45"}
    };
    for(String[] db : dbs) {
      try {
        Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/"+db[0],db[1],db[2]);
        System.out.println("=== DB: "+db[0]+" ===");
        Statement st = c.createStatement();
        ResultSet tables = st.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public'");
        while(tables.next()) {
          String t = tables.getString(1);
          try {
            ResultSet cols = c.createStatement().executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='"+t+"' AND data_type IN ('character varying','text') LIMIT 10");
            while(cols.next()) {
              String col = cols.getString(1);
              try {
                ResultSet r = c.createStatement().executeQuery("SELECT \""+col+"\" FROM \""+t+"\" WHERE \""+col+"\" LIKE '%xnd_%' LIMIT 2");
                while(r.next()) {
                  String v = r.getString(1);
                  if(v != null && v.length() > 3) System.out.println("  "+t+"."+col+" = "+v.substring(0,Math.min(150,v.length())));
                }
              } catch(Exception e) {}
            }
          } catch(Exception e) {}
        }
        c.close();
      } catch(Exception e) {
        System.out.println("=== DB "+db[0]+" FAIL: "+e.getMessage());
      }
    }
  }
}
