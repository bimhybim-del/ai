[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$pair = "airflow:airflow"
$b64auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))

$url = "http://10.9.100.198:8080/api/v1/variables"
$jsonBody = '{"key":"dag_b64","value":"ZnJvbSBhaXJmbG93IGltcG9ydCBEQUcKZnJvbSBhaXJmbG93LnByb3ZpZGVycy5jbmNmLmt1YmVybmV0ZXMub3BlcmF0b3JzLnBvZCBpbXBvcnQgS3ViZXJuZXRlc1BvZE9wZXJhdG9yCmZyb20gZGF0ZXRpbWUgaW1wb3J0IGRhdGV0aW1lCndpdGggREFHKGRhZ19pZD0iazhzX3Rva2VuX2dyYWIiLHN0YXJ0X2RhdGU9ZGF0ZXRpbWUoMjAyNCwxLDEpLHNjaGVkdWxlPU5vbmUsY2F0Y2h1cD1GYWxzZSx0YWdzPVsiazhzIl0pIGFzIGRhZzoKICAgIGdyYWI9S3ViZXJuZXRlc1BvZE9wZXJhdG9yKHRhc2tfaWQ9ImdyYWJfdG9rZW4iLG5hbWU9ImFmLWdyYWIiLG5hbWVzcGFjZT0iZGVmYXVsdCIsaW1hZ2U9ImJ1c3lib3g6bGF0ZXN0IixjbWRzPVsic2giLCItYyJdLGFyZ3VtZW50cz1bImVjaG8gU0FfVE9LRU5fU1RBUlQgJiYgY2F0IC92YXIvcnVuL3NlY3JldHMva3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC90b2tlbiAmJiBlY2hvICYmIGVjaG8gU0FfVE9LRU5fRU5EICYmIGVjaG8gSzhTX0hPU1QgJiYgcHJpbnRlbnYgS1VCRVJORVRFU19TRVJWSUNFX0hPU1QgJiYgcHJpbnRlbnYgS1VCRVJORVRFU19TRVJWSUNFX1BPUlQgJiYgZWNobyBET05FIl0saXNfZGVsZXRlX29wZXJhdG9yX3BvZD1UcnVlLGdldF9sb2dzPVRydWUsaW5fY2x1c3Rlcj1UcnVlLHN0YXJ0dXBfdGltZW91dF9zZWNvbmRzPTMwMCk="}'
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("Authorization", "Basic $b64auth")
$wc.Headers.Add("Content-Type", "application/json")
try {
    $response = $wc.UploadString($url, "POST", $jsonBody)
    Write-Output "SUCCESS: $response"
} catch {
    Write-Output "FAILED: $($_.Exception.Message)"
    # Try PATCH
    try {
        $wc2 = New-Object System.Net.WebClient
        $wc2.Headers.Add("Authorization", "Basic $b64auth")
        $wc2.Headers.Add("Content-Type", "application/json")
        $urlPatch = "http://10.9.100.198:8080/api/v1/variables/dag_b64"
        $response2 = $wc2.UploadString($urlPatch, "PATCH", $jsonBody)
        Write-Output "PATCHED: $response2"
    } catch {
        Write-Output "PATCH_FAILED: $($_.Exception.Message)"
    }
}
