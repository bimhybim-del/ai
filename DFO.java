import java.sql.*;
class DFO {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/venus","venus","K6Yr4RV6jsBCjae4");
    System.out.println("VENUS DB CONNECTED!");
    Statement s = c.createStatement();
    System.out.println("---APP-SETTING---");
    ResultSet r = s.executeQuery("SELECT * FROM app_setting WHERE lower(key) LIKE '%xendit%' OR lower(value) LIKE '%xnd_%' OR lower(key) LIKE '%payment%' OR lower(key) LIKE '%api%'");
    ResultSetMetaData md = r.getMetaData();
    for(int i=1;i<=md.getColumnCount();i++) System.out.print(md.getColumnName(i)+"|");
    System.out.println();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v=r.getString(i);
        System.out.print((v!=null?v.substring(0,Math.min(300,v.length())):"null")+"|");
      }
      System.out.println();
    }
    // Also query payment_point  
    System.out.println("---PAYMENT-POINT---");
    r = s.executeQuery("SELECT * FROM payment_point WHERE lower(value) LIKE '%xnd_%' OR lower(key) LIKE '%xendit%' LIMIT 5");
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
    // Dump ALL from app_setting
    System.out.println("---ALL-APP-SETTINGS---");
    r = s.executeQuery("SELECT * FROM app_setting");
    md = r.getMetaData();
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
