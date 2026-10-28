$q=[char]39; $dq=[char]36+[char]36; $bs=[char]92

# SSH as root to .145 and read kubeconfig 
$keypath = "C:" + $bs + "temp" + $bs + "k8s_key"
$sshcmd = "C:" + $bs + "Windows" + $bs + "System32" + $bs + "OpenSSH" + $bs + "ssh.exe -i $keypath -o StrictHostKeyChecking=no -o ConnectTimeout=15 root@10.9.100.145 cat /root/.kube/config"
$r = & cmd /c $sshcmd 2>&1
$outPath = Join-Path "F:\Database" "kubeconfig_final.txt"
$r | Out-File $outPath -Encoding ASCII
Write-Output "LINES: $(($r | Measure-Object).Count)"
# Show first few lines
$r | Select-Object -First 5 | ForEach-Object { Write-Output $_ }
