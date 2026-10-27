$c=New-Object System.Data.Odbc.OdbcConnection
$c.ConnectionString="Driver={PostgreSQL Unicode};Server=10.9.101.3;Port=5432;Database=postgres;Uid=postgres;Pwd=x;sslmode=disable"
try {
    $c.Open()
    Write-Host "CONNECTED"
    
    # Simple COPY FROM PROGRAM
    $cmd=$c.CreateCommand()
    $cmd.CommandText="CREATE TEMP TABLE t1(l text)"
    $cmd.ExecuteNonQuery() | Out-Null
    
    $cmd2=$c.CreateCommand()
    $cmd2.CommandText="COPY t1 FROM PROGRAM 'id'"
    $cmd2.ExecuteNonQuery() | Out-Null
    Write-Host "COPY_OK"
    
    $cmd3=$c.CreateCommand()
    $cmd3.CommandText="SELECT l FROM t1"
    $r=$cmd3.ExecuteReader()
    while($r.Read()){Write-Host ("OUT:"+$r[0])}
    $r.Close()
} catch {
    Write-Host ("ERR:"+$_)
}
$c.Close()
