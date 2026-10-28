$headers = @{"Content-Type" = "application/json"}
$body1 = '{"secret_key":"OjkmU+BtpVZ7VJlI4nO4uWafXUI3WVY4V9nIM6xZXs38Jmns+CvQAMlnTTutIXw7","source_application":"KPM"}'
$body2 = '{"secret_key":"j4Cfspn7XleRHWRI8MB3aE+/acOiho78h8Fq4kQxS/MlZpPLcyaLrpBonB5OfCvopT+nJWlUf1lHHQ==","source_application":"KPM"}'

Write-Host "=== Trying SECRET_KEY ==="
try {
    $r1 = Invoke-RestMethod -Uri "https://10.9.100.47/v1/auth/login" -Method POST -Headers $headers -Body $body1 -SkipCertificateCheck -ErrorAction Stop
    $r1 | ConvertTo-Json -Depth 5
} catch {
    $_.Exception.Response.StatusCode
    $_.ErrorDetails.Message
}

Write-Host "=== Trying PP_KPM_SECRET_KEY ==="
try {
    $r2 = Invoke-RestMethod -Uri "https://10.9.100.47/v1/auth/login" -Method POST -Headers $headers -Body $body2 -SkipCertificateCheck -ErrorAction Stop
    $r2 | ConvertTo-Json -Depth 5
} catch {
    $_.Exception.Response.StatusCode
    $_.ErrorDetails.Message
}

Write-Host "=== Trying with dev-platform-auth IP 103.183.18.219 ==="
try {
    $r3 = Invoke-RestMethod -Uri "https://103.183.18.219/v1/auth/login" -Method POST -Headers $headers -Body $body2 -SkipCertificateCheck -ErrorAction Stop
    $r3 | ConvertTo-Json -Depth 5
} catch {
    $_.Exception.Response.StatusCode
    $_.ErrorDetails.Message
}
