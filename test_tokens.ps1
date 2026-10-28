Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAll : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAll
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

function Test-K8s($token, $label) {
    try {
        $req = [System.Net.WebRequest]::Create("https://10.9.100.10:6443/api/v1/namespaces")
        $req.Method = "GET"
        $req.Headers.Add("Authorization", "Bearer $token")
        $resp = $req.GetResponse()
        $r = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $body = $r.ReadToEnd()
        Write-Host "=== $label: SUCCESS ==="
        Write-Host $body
        return $true
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $body = $r.ReadToEnd()
            Write-Host "=== $label: FAIL ($([int]$_.Exception.Response.StatusCode)) ==="
            Write-Host $body
        } else {
            Write-Host "=== $label: NET ERROR === $($_.Exception.Message)"
        }
        return $false
    }
}

# All tokens to test
$tokens = @{
    "confins-r3-api-key-raw" = "SVVieUNlT3VvNFp3UlBHd1BhY3hSUWdMRGQzTi9hYm9memhnRlFyTjJ2NFNZUz0="
    "confins-r3-api-key-decoded" = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("SVVieUNlT3VvNFp3UlBHd1BhY3hSUWdMRGQzTi9hYm9memhnRlFyTjJ2NFNZUz0="))
    "opex-platform-auth-token" = "9j4XIgyyvNrLC2XlW9gMziyJ8aOXkwYlvQLNTTqWcteNn7+51kfnS0AnJo8HEV5aD8bQ5KqzUhiXHNIEDaRjkLNb9IgwfuDGrt9IknOa9vTkqDH2qg96eN0wioCjD2kvPArm80pfJMjPWbrjepBQCPkXKszOlu5dIBrawFn3cZWma56Oc57EZUnpoaWFsPDjRTelviXTdR6cbqxc0Mc29rE/sm2DMdrHiWVzCZDH2wywSe5ka5ad5teUbBZdAlgP35DgGdlPrEkPITJ8jpL5G5W0L6BdgefUyjltD4gV9Bq8ytRZ7xy4IlYqIEheAJvoReBnsm5sG2Ag5PTpwmy380LK4dCmMwqTt6l1A35Vm131jdVCezGSngXGx11H47Opipu7ZdmcXeE3rWoA9SP9gS3ItGpV/tY//GSmzGYtWe5jkpkbjhMX3OPGl9O+LB5aBOQd19M6udu2hcT5wP9kxjwSo2yd4qGiDgNkUB0KCJ8pr9cMwJx5qqSHDfyVZWSGFIRelb/ul85cOL5sFYLwU6QAOqdENF52qQ2JS1CfKK6gCrQ+Vsq0RICceSaMhLnJg+4U457L3aV/EkT/EX2e09xcBb3Suk63WyU9eC81Pw7pSFFxLyZb+u8/FxRkitnPkcwOdtOgwGQr1prW0lZi0a2Fz6sFCihFqdd6WKRYFKcqEK+aNId/rPoMNrwRkz1dFaD0sBmx7kaV6he3sHsm6O3eb0XyF6fJS6XE3adoDhIuSz/W3ZwMYlVCHWxSc+STAgLeUeO2KebCWxi663RjohOhxg6nGvfxme5qK86SqUjlQe9GXqbaSfoiGZUXnpbshCJiO8CkJDeMlR/6PLRtGhiUm9Tl10bpKmNMmCn9HBqmcoyMQ6lWPCIMMh8fQZgK4g=="
    "INDOMARET-ACCESS-TOKEN" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJJbmRvbWFyZXQuQXBpIiwiZXhwIjoxNzc2ODE4NDU1LCJpYXQiOjE3NzY4MTgxNTUsImlzcyI6IlBUIEtCIEZpbmFuc2lhIE11bHRpIEZpbmFuY2UifQ.aOJ055Z8ZwrO11wQxP0dba3qiPzqSWXwjocwBhXPmEI"
    "SYB-TOKEN" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJTeWIuQXBpIiwiZXhwIjoxNzc2ODI1NDI5LCJpYXQiOjE3NzY4MjA0MjksImlzcyI6IlBUIEtCIEZpbmFuc2lhIE11bHRpIEZpbmFuY2UifQ.k_ohl8YR9MnwG6xrli05timCVGrT6OqA4n_x2TAV4q0"
    "TOKOPEDIA-TOKEN" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJUb2tvcGVkaWEuQXBpIiwiZXhwIjoxNzc2ODM3MTY3LCJpYXQiOjE3NzY4MzIxNjcsImlzcyI6IlBUIEtCIEZpbmFuc2lhIE11bHRpIEZpbmFuY2UifQ.DCwAdXcxJtaH4qSuCrpNxo7eZFiY7-gKLJ6cMbtvpk0"
    "dbdocs-token" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NTMxMTMsInRva2VuIjoiYmMwOGMyYzMyZjkwYWQ3MzEyYjlmYTBjYzAyZmQ0NDIiLCJpYXQiOjE3NjQwNTA4MTR9.Bhrskrzg_kfxEdmFEBIB8lcj_nW2N9obL7Oe9AP-Dcw"
}

foreach ($label in $tokens.Keys) {
    Test-K8s $tokens[$label] $label
}

# Also try K8s healthz without token
Write-Host "`n=== K8s API healthz ==="
try {
    $req = [System.Net.WebRequest]::Create("https://10.9.100.10:6443/healthz")
    $req.Method = "GET"
    $resp = $req.GetResponse()
    $r = New-Object System.IO.StreamReader($resp.GetResponseStream())
    Write-Host $r.ReadToEnd()
} catch [System.Net.WebException] {
    if ($_.Exception.Response) {
        $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        Write-Host $r.ReadToEnd()
    }
}

# Try K8s /api without token
Write-Host "`n=== K8s /api no token ==="
try {
    $req = [System.Net.WebRequest]::Create("https://10.9.100.10:6443/api")
    $req.Method = "GET"
    $resp = $req.GetResponse()
    $r = New-Object System.IO.StreamReader($resp.GetResponseStream())
    Write-Host $r.ReadToEnd()
} catch [System.Net.WebException] {
    if ($_.Exception.Response) {
        $r = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        Write-Host $r.ReadToEnd()
    }
}
