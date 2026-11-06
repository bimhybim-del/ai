import java.sql.*;
class XF3 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    ResultSet r = s.executeQuery("SELECT * FROM app_setting WHERE lower(key) LIKE '%xendit%' OR lower(value) LIKE '%xnd_%' OR lower(key) LIKE '%payment%' ORDER BY key");
    ResultSetMetaData md = r.getMetaData();
    int cols = md.getColumnCount();
    for(int i=1;i<=cols;i++) System.out.print(md.getColumnName(i)+"|");
    System.out.println();
    while(r.next()) {
      for(int i=1;i<=cols;i++) System.out.print(r.getString(i)+"|");
      System.out.println();
    }
    c.close();
  }
}
