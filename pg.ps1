$c=New-Object System.Data.Odbc.OdbcConnection
$c.ConnectionString="DSN=Stag_Kreditmu"
try {
    $c.Open()
    Write-Host "PG_CONNECTED"
    $cmd=$c.CreateCommand()
    $cmd.CommandText="SELECT current_user, current_database(), version()"
    $r=$cmd.ExecuteReader()
    while($r.Read()){
        Write-Host "PG_USER:$($r[0])"
        Write-Host "PG_DB:$($r[1])"
        Write-Host "PG_VER:$($r[2])"
    }
    $r.Close()
    
    # List databases
    $cmd2=$c.CreateCommand()
    $cmd2.CommandText="SELECT datname FROM pg_database WHERE datistemplate=false"
    $r2=$cmd2.ExecuteReader()
    while($r2.Read()){Write-Host "PG_DBNAME:$($r2[0])"}
    $r2.Close()
    
    $c.Close()
} catch {
    Write-Host "PG_ERR:$_"
}
