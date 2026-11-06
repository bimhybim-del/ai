import java.sql.*;
class DF3 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    // _accurate_mcp app_setting
    System.out.println("===_ACCURATE_MCP APP_SETTING===");
    try {
      Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/_accurate_mcp","neo","BJwx+sAC6jreaV45");
      ResultSet r = c.createStatement().executeQuery("SELECT * FROM app_setting");
      ResultSetMetaData md = r.getMetaData();
      for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
      System.out.println();
      while(r.next()) { for(int i=1;i<=md.getColumnCount();i++){String v=r.getString(i);System.out.print((v!=null?v.substring(0,Math.min(200,v.length())):"null")+"|");}System.out.println(); }
      c.close();
    } catch(Exception e) { System.out.println("FAIL: "+e.getMessage()); }

    // ACLS digital_key_pair + configuration
    System.out.println("===ACLS DIGITAL_KEY_PAIR===");
    try {
      Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/acls","neo","BJwx+sAC6jreaV45");
      ResultSet r = c.createStatement().executeQuery("SELECT * FROM digital_key_pair LIMIT 5");
      ResultSetMetaData md = r.getMetaData();
      for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
      System.out.println();
      while(r.next()) { for(int i=1;i<=md.getColumnCount();i++){String v=r.getString(i);System.out.print((v!=null?v.substring(0,Math.min(100,v.length())):"null")+"|");}System.out.println(); }
      System.out.println("===ACLS CONFIGURATION===");
      r = c.createStatement().executeQuery("SELECT * FROM configuration LIMIT 10");
      md = r.getMetaData();
      for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
      System.out.println();
      while(r.next()) { for(int i=1;i<=md.getColumnCount();i++){String v=r.getString(i);System.out.print((v!=null?v.substring(0,Math.min(200,v.length())):"null")+"|");}System.out.println(); }
      c.close();
    } catch(Exception e) { System.out.println("FAIL: "+e.getMessage()); }

    // SERMO accurate_credential
    System.out.println("===SERMO ACCURATE_CREDENTIAL===");
    try {
      Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/sermo","neo","BJwx+sAC6jreaV45");
      ResultSet r = c.createStatement().executeQuery("SELECT * FROM accurate_credential LIMIT 10");
      ResultSetMetaData md = r.getMetaData();
      for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
      System.out.println();
      while(r.next()) { for(int i=1;i<=md.getColumnCount();i++){String v=r.getString(i);System.out.print((v!=null?v.substring(0,Math.min(150,v.length())):"null")+"|");}System.out.println(); }
      c.close();
    } catch(Exception e) { System.out.println("FAIL: "+e.getMessage()); }
  }
}
