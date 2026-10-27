Import-Module Posh-SSH
$pw = ConvertTo-SecureString "ElJ4I`$xX" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("admin_i3",$pw)
try {
    $s = New-SSHSession -ComputerName 10.9.101.3 -Credential $cred -AcceptKey -ErrorAction Stop -ConnectionTimeout 10
    $r = Invoke-SSHCommand -SSHSession $s -Command "id; echo ===SUDO===; sudo -l 2>&1; echo ===KUBE===; ls -la /root/.kube/ 2>&1; ls -la ~/.kube/ 2>&1; echo ===GROUPS===; groups"
    Write-Host "RESULT:"
    Write-Host $r.Output
    Remove-SSHSession $s | Out-Null
} catch {
    Write-Host ("ERR:"+$_)
}
