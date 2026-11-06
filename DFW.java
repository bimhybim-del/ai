import java.sql.*;
class DFW {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    System.out.println("---ALL-COLUMNS---");
    ResultSet r = c.createStatement().executeQuery("SELECT column_name,data_type FROM information_schema.columns WHERE table_name='e_payment_register' ORDER BY ordinal_position");
    while(r.next()) System.out.println(r.getString(1)+" ("+r.getString(2)+")");
    // Check if there's a SEPARATE secret_key column or encrypted key
    System.out.println("---FULL-ROW-557---");
    r = c.createStatement().executeQuery("SELECT * FROM e_payment_register WHERE id=557");
    ResultSetMetaData md = r.getMetaData();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v=r.getString(i);
        System.out.println(md.getColumnName(i)+" = "+(v!=null?v:"null"));
      }
    }
    c.close();
  }
}
