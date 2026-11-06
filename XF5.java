import java.sql.*;
class XF5 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    ResultSet r = s.executeQuery("SELECT count(*) FROM app_setting");
    r.next();System.out.println("TOTAL_ROWS:"+r.getInt(1));
    r = s.executeQuery("SELECT id,type,substring(value,1,200) FROM app_setting WHERE lower(type) LIKE '%xendit%' OR lower(value) LIKE '%xnd_%' OR lower(value) LIKE '%xendit%'");
    while(r.next()) System.out.println(r.getString(1)+"|||"+r.getString(2)+"|||"+r.getString(3));
    System.out.println("---ALL-TYPES---");
    r = s.executeQuery("SELECT DISTINCT type FROM app_setting ORDER BY type");
    while(r.next()) System.out.println(r.getString(1));
    c.close();
  }
}
