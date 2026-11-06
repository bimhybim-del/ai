import java.sql.*;
class DF5 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    // Settings tables in other DBs
    String[] dbs = {"gemini","leo","pisces","taurus"};
    for(String db : dbs) {
      System.out.println("==="+db+" SETTING===");
      try {
        Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/"+db,"neo","BJwx+sAC6jreaV45");
        ResultSet r = c.createStatement().executeQuery("SELECT * FROM setting");
        ResultSetMetaData md = r.getMetaData();
        for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
        System.out.println();
        while(r.next()) { for(int i=1;i<=md.getColumnCount();i++){String v=r.getString(i);System.out.print((v!=null?v.substring(0,Math.min(200,v.length())):"null")+"|");}System.out.println(); }
        c.close();
      } catch(Exception e) { System.out.println("  FAIL: "+e.getMessage().substring(0,Math.min(80,e.getMessage().length()))); }
    }
    // Venus app_setting (different from billing_payment)
    System.out.println("===VENUS APP_SETTING===");
    try {
      Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/venus","neo","BJwx+sAC6jreaV45");
      ResultSet r = c.createStatement().executeQuery("SELECT * FROM app_setting WHERE lower(key) LIKE '%xendit%' OR lower(value) LIKE '%xnd_%' OR lower(key) LIKE '%payment%'");
      ResultSetMetaData md = r.getMetaData();
      for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
      System.out.println();
      while(r.next()) { for(int i=1;i<=md.getColumnCount();i++){String v=r.getString(i);System.out.print((v!=null?v.substring(0,Math.min(200,v.length())):"null")+"|");}System.out.println(); }
      c.close();
    } catch(Exception e) { System.out.println("  FAIL: "+e.getMessage().substring(0,Math.min(100,e.getMessage().length()))); }
  }
}
