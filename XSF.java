import java.sql.*;
class XSF {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    Connection c = DriverManager.getConnection("jdbc:postgresql://10.13.17.248:5501/neo","neo","BJwx+sAC6jreaV45");
    Statement s = c.createStatement();
    System.out.println("---DISB-LOG-COLS---");
    ResultSet r = s.executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='xendit_disbursement_log'");
    while(r.next()) System.out.print(r.getString(1)+",");
    System.out.println();
    System.out.println("---QRIS-LOG-COLS---");
    r = s.executeQuery("SELECT column_name FROM information_schema.columns WHERE table_name='xendit_qris_log'");
    while(r.next()) System.out.print(r.getString(1)+",");
    System.out.println();
    // Sample from xendit_qris_log - might contain API keys in request
    System.out.println("---QRIS-LOG-SAMPLE---");
    r = s.executeQuery("SELECT id,substring(request_body,1,400),substring(response_body,1,200) FROM xendit_qris_log ORDER BY id DESC LIMIT 2");
    while(r.next()) System.out.println("ID="+r.getString(1)+"|REQ="+r.getString(2)+"|RESP="+r.getString(3));
    // Also check xendit_disbursement_log
    System.out.println("---DISB-LOG-SAMPLE---");
    r = s.executeQuery("SELECT * FROM xendit_disbursement_log ORDER BY id DESC LIMIT 2");
    ResultSetMetaData md = r.getMetaData();
    while(r.next()) {
      for(int i=1;i<=md.getColumnCount();i++) {
        String v=r.getString(i);
        if(v!=null&&v.length()>0) System.out.print(md.getColumnName(i)+"="+v.substring(0,Math.min(150,v.length()))+"|");
      }
      System.out.println();
    }
    c.close();
  }
}
