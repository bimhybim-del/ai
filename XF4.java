import java.sql.*;
class XF4 {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    ResultSet r = s.executeQuery("SELECT column_name,data_type FROM information_schema.columns WHERE table_name='app_setting' ORDER BY ordinal_position");
    while(r.next()) System.out.println(r.getString(1)+"|"+r.getString(2));
    System.out.println("---DUMP---");
    r = s.executeQuery("SELECT * FROM app_setting LIMIT 20");
    ResultSetMetaData md = r.getMetaData();
    int cols = md.getColumnCount();
    for(int i=1;i<=cols;i++) System.out.print(md.getColumnName(i)+"|||");
    System.out.println();
    while(r.next()) {
      for(int i=1;i<=cols;i++) {
        String v = r.getString(i);
        System.out.print((v!=null?v.substring(0,Math.min(100,v.length())):"null")+"|||");
      }
      System.out.println();
    }
    c.close();
  }
}
