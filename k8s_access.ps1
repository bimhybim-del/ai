Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAll : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAll
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$platform_token = "fjTD1tLxeFhym/JrLvr/x6qL8bnivMvRt//WYy3KooH7u5rChkYhuoPImzi3CXcBygo7UDDKgxMqX5YPRNoiUTa7ohYpht3e1VqkJbPxY6V7B1K7yo/zVHIqQEqy6wS75gz/jkxMh0Bl+CnYKjv//jaAq7gK7XRmN3PkuvQVn7/RTGSuNImtD/DBt/WBzS7oUcR/LjQ5fZEEtqsu541VWkfuvXhdCGdCxBcPl+LBYdUo3C1wkjfFP2rwv45+30krnfCKA6DHDu77dcxCpBX+ovovaQ3z8R2rde0nV2z9/TkxWPareL3/ElhhaikoOwD3XU5cHgcK1jYUGR0ugCTyvQbOXk4g2KJVLrP2RMMqqe3MCOQ/NzxgG0mj+WbuHUA5iNJVE0O4+xw+SgKqKJwx+i/Edw1hTxTdp29CghfSUC7gb6NS84f1r7VHJdlY5Ge7RxcbYZLKpf8Fl/m4onN0wxVrgUCN8gXiBgzSzVU1NwJYPoL99g2dvQocVTLCRYyqH4u8fFk/UPjp2YdIkFI2ul8QXKFNQ1Goh7baB3H0dm8NgypuOL2aJgu98WjxMrVus/4iFNk51P45MY2wZApCKOAiCp44C5IfU0mzS8b+Oaykn8Ib7I4r4mpHf3BEa8tqXWF8/g3vSPqU0AOwLgE/I78iFFd+g8ldOsQg77aAx9TBsx20Nzl7ZRtWq5AzMN2EJVsWOv2Ckv6shnjHMD+MQc/aphwez5kLCgksqWll/4BZTEgDvI3wSD/uW9FRpbZDs/r48ixo4j7U0rf5qe+5EL52JMqpacpE/1C5YwvsAYsnd+Ru5Bz65O29GLLj1+8mNg1xC8QUrC6G8RIDLI4FoewXOTkuiUdjo6/Dwild9YRoMp4hX/QuII8MdmV31ao="

# 1. Try platform token directly on K8s
Write-Host "=== Testing platform token on K8s ==="
$k8s_urls = @(
    "https://10.9.100.10:6443/api/v1/namespaces",
    "https://10.9.100.10:6443/api/v1/pods",
    "https://10.9.100.10:6443/apis"
)
foreach ($url in $k8s_urls) {
    try {
        $req = [System.Net.WebRequest]::Create($url)
        $req.Method = "GET"
        $req.Headers.Add("Authorization", "Bearer $platform_token")
        $resp = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        Write-Host "K8S SUCCESS ($url): " $reader.ReadToEnd().Substring(0, [Math]::Min(500, $reader.BaseStream.Length))
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            Write-Host "K8S FAIL ($url): " $reader.ReadToEnd()
        }
    }
}

# 2. Get Airflow connections for K8s
Write-Host "`n=== Getting Airflow connections ==="
$encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("airflow:airflow"))
$conn_urls = @(
    "https://dev-airflow.kbfinansia.com/api/v1/connections?limit=100",
    "https://dev-airflow.kbfinansia.com/api/v1/connections?limit=100&offset=0"
)
foreach ($url in $conn_urls) {
    try {
        $req = [System.Net.WebRequest]::Create($url)
        $req.Method = "GET"
        $req.Headers.Add("Authorization", "Basic $encoded")
        $resp = $req.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        Write-Host "CONNECTIONS: " $reader.ReadToEnd()
    } catch [System.Net.WebException] {
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            Write-Host "CONN FAIL: " $reader.ReadToEnd()
        }
    }
}
