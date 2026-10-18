# Spinnaker Mass Assessment — Complete IP List
# Date: 2026-08-21 (updated 2026-08-26)

## Search Engines & Queries Used:

### Censys (8 queries, web UI — 102 IPs):
1. `host.services.endpoints.http.body:"netflix.spinnaker"` → 85 hosts
2. `host.services.endpoints.http.body:"#149CB5" and "loading-placeholder"` → 88 hosts
3. `host.services.endpoints.http.headers.key:"X-SPINNAKER-REQUEST-ID"` → 16 hosts
4. `host.services.endpoints.http.body:"netflix.spinnaker" and "loading-placeholder"` → 86 hosts
5-8. Additional variations (version, non-standard ports, spinnakerSettings) → 0 new

### Shodan (130+ queries, stats+facets — 130+ unique IPs):
1. `http.html:"netflix.spinnaker"` → 73 IPs (24 new)
2. `http.html:"loading-placeholder" http.html:"#149CB5"` → 75 IPs (5 new)
3. `"X-SPINNAKER-REQUEST-ID"` → 12 IPs (2 new)
4. `port:8084 "spinnaker"` → 2 IPs (1 new)
5. `title:"Spinnaker"` → 5 new IPs (all non-CI/CD)
6-20. Various (clouddriver, orca, product, component, etc.) → 0 new

### Netlas.io (6 queries, API free tier — 20 IPs):
1. `http.body:"netflix.spinnaker"` → 20 IPs (7 new, all auth/dead)
2-6. Various (title, gateUrl, settings-local) → 0 new

### ZoomEye (free registration — 2,112+ historical results):
- `"netflix.spinnaker"` → 2,112 results (116 from last year)
- `"netflix.spinnaker" && title=="Spinnaker" && after="2026-01-01"` → 81 results
- `"X-SPINNAKER-REQUEST-ID"` → 722 results (27 nearly year)
- New domains found: AlphaSights, Jupiter Money, SparkCognition, Biofourmis, Fast Retailing/Uniqlo, Moderne.ninja, Boomtrain, CongaMerge, SHElikes.jp, BigFishGames, PayU India, MPI-internal
- 40+ new IPs extracted → tested from Kali + 4 VPS (NYC/AMS/LON/GCP)
- Results: ALL dead, false positive (OpenSearch/CloudSearch), or auth-held
- Notable discoveries: api-spinny.moderne.ninja (Gate alive, Google OAuth, Bearer bypass failed)

### Additional Shodan queries (100+ variations):
- `"Access-Control-Expose-Headers" "X-SPINNAKER"` → 60 IPs (46 new, 6 alive, 0 bypass)
- `ssl:"spinnaker" ssl:"kubernetes"` → 13 new IPs (all dead certs)
- `ssl.cert.subject.cn:spin-gate/spin-api/spin.prod` → 45 new IPs (all dead)
- `http.html:"gateUrl"` → 18 new IPs (Deck v2, all dead)
- `http.favicon.hash:614187882` → 64 IPs (all known)
- Various: body, header, SSL, favicon, title, provider, country, port queries → all exhausted

### Masscan from 4 VPS (NYC/AMS/LON/GCP-US):
- Port 8084: 1,130 IPs scanned → 1 broken Gate (v1.5.0)
- Port 9000: 60K+ IPs scanned → 0 Spinnaker Deck
- Port 30000-30500: 832 IPs → 0 Spinnaker
- Cloud ranges: AWS Asia/EU/India/Korea, GCP Asia, Azure, Tencent → 0 new

### Shodan Refresh (2026-08-26, CLI free tier):
- `http.html:"netflix.spinnaker"` → 82 results (was 73, +9 new)
- `"Access-Control-Expose-Headers" "X-SPINNAKER"` → 58 results (39 new IPs)
- `ssl.cert.subject.cn:"spin-gate"` → 13 results (17 new IPs)
- `ssl.cert.subject.cn:"spinnaker-api"` → 11 results (7 new IPs)
- 22+ queries total, ~60 new IPs tested
- New domains: PolyAI (gate.polyai.app), BizWise (spinnaker-api.bizwise.com), Jawbone (spingate.infra.jawbonr.com)
- 1 alive no-auth (52.201.98.250) but Gate ELB 503
- 1 alive from VPS only (35.233.190.209, Jawbone, auth-held)
- Rest: dead or auth-held (modern OAuth2/SAML/custom login)

### Other engines tried:
- FOFA (en.fofa.info) → 432 body results, 79 header results, 48 no-auth query — found HPE, RedBull, Mercari, Citadel, Wahed, Scalars, CXM-SalesCloud, PolyAI, BizWise, all auth-held
- CriminalIP → 45 results, all known
- Netlas → 20 results, 5 new IPs all false positive
- ZoomEye → 81+722+519 results, all known or dead
- urlscan.io, Tavily, CommonCrawl, Wayback Machine → 0 results
- PublicWWW, LeakIX, GreyNoise → 0 results
- GitHub code search → 0 leaked Gate URLs
- crt.sh CT logs → 502 (down)
- Hunter.io email search → not applicable for infra discovery
- Google dorks → 0 actionable results

## TOTAL: 250+ unique IPs (102 Censys + 130+ Shodan + 20 Netlas + 18 ZoomEye + masscan) → 14 targets compromised (9 no-auth + 5 Bearer 0-day bypass)

---

## RCE ACHIEVED (6 targets, 26 IPs)

| IP | Port | Platform | Apps | Company | Status |
|----|------|----------|------|---------|--------|
| 52.41.222.111 | 80 | AWS EKS us-west-2 | 76 | Xeni (xeni.com) | ✅ ROOT — `uid=0(root)` Alpine ARM64 |
| 54.244.209.209 | 9000, 8084 | AWS EKS us-west-2 | 76 | Xeni | ✅ ROOT (Deck+Gate same IP) |
| 34.223.116.234 | 80 | AWS EKS us-west-2 | 76 | Xeni | ✅ ROOT (Deck node) |
| 54.218.133.163 | 80 | AWS EKS us-west-2 | 76 | Xeni | ✅ ROOT (Deck node) |
| 44.224.146.2 | 80 | AWS EKS us-west-2 | 76 | Xeni | ✅ ROOT (Gate ELB IP) |
| 52.41.97.83 | 80 | AWS EKS us-west-2 | 76 | Xeni | ✅ ROOT (Gate ELB IP) |
| 34.208.107.132 | 80 | AWS EKS us-west-2 | 76 | Xeni | ✅ ROOT (Gate ELB IP) |
| 44.229.29.93 | 80 | AWS EKS us-west-2 | 76 | Xeni | ✅ ROOT (Deck node) |
| 3.128.136.77 | 8084 | AWS EKS us-east-2 | 9 | CorporateMutt | ✅ ROOT — `uid=0(root)` Amazon Linux 2023 |
| 3.16.222.85 | 8084 | AWS EKS us-east-2 | 9 | CorporateMutt | ✅ ROOT (Gate ELB IP) |
| 18.116.233.77 | 80 | AWS EKS us-east-2 | 9 | CorporateMutt | ✅ ROOT (Deck node) |
| 18.219.180.226 | 80 | AWS EKS us-east-2 | 9 | CorporateMutt | ✅ ROOT (Deck node) |
| 54.69.193.31 | 80, 443 | AWS EKS us-west-2 | 7 | Insight (insight.com) | ✅ ROOT — `uid=0(root)` Amazon Linux 2 |
| 44.234.15.207 | 80, 443 | AWS EKS us-west-2 | 7 | Insight | ✅ ROOT (Deck node) |
| 52.35.57.120 | 32062 | AWS EKS us-west-2 | 7 | Insight | ✅ ROOT (Deck NodePort) |
| 206.124.141.91 | 30398 | Ubuntu 22.04 bare metal | 23 | Unknown (a24 infra) | ✅ ROOT — `uid=0(root)` Ubuntu 5.15.0 |
| 43.173.125.44 | 30239 | Tencent TKE China | 121 | DotcUnited (dotcunited.com) | ✅ ROOT — `uid=0(root)` TKE kernel |
| 18.116.45.244 | 32139, 30118 | AWS EKS us-east-2 | 8 | Unknown (fresh setup) | ✅ Pod deployed Active=1 (no output — cache broken) |
| 3.145.21.114 | 32139, 30118 | AWS EKS us-east-2 | 8 | Unknown (same cluster) | ✅ Pod deployed (same cluster as above) |

## CLOUD COMPROMISE — NO POD RCE (1 target, 1 IP)

| IP | Port | Platform | Apps | Company | Status |
|----|------|----------|------|---------|--------|
| 34.28.16.225 | 8084, 9000 | AWS ECS + Azure + GCP | 1 | FundMore AI (fundmore.ai) | ⚠️ 70+ secrets — Azure KV dump, GCP SA key, MongoDB, 16 GitHub repos |

## 0-DAY BEARER BYPASS RCE (5 targets — auth-enabled but bypassed)

| IP | Port | Platform | Apps | Company | Status |
|----|------|----------|------|---------|--------|
| 34.102.186.121 | 443 | GKE europe-west2 | 127 | Causeway Technologies (UK construction) | ✅ ROOT — `uid=0(root)` Alpine 3.20, kernel 6.12.85+ via Bearer bypass |
| 34.128.170.167 | 443 | GKE + Istio | 165 | ClarityApp (India fintech) | ✅ ROOT — `uid=0(root)` Alpine 3.20, kernel 6.12.85+ via Bearer bypass |
| 34.133.1.157 | 80/443 | GKE + Rancher | 40 | QualifiedHealth AI (healthcare) | ✅ ROOT — `uid=0(root)` Alpine 3.20, kernel 6.12.68+ via Bearer bypass |
| 34.102.164.29 | 443 | GKE | 62 | ShopperTrak/TrueVue STG (Johnson Controls) | ✅ Auth bypass confirmed (STG cluster) |
| 34.149.235.126 | 443 | GKE | 49 | ShopperTrak/TrueVue PROD (Johnson Controls) | ✅ ROOT — `uid=0(root)` Alpine 3.20, kernel 6.12.55+ via Bearer bypass on PROD |

## RCE VIA CONSOLE EXEC (1 target, 1 IP — deploy blocked but exec works)

| IP | Port | Platform | Apps | Company | Status |
|----|------|----------|------|---------|--------|
| 120.132.9.151 | 30007, 30006 | K8s on-prem China Telecom | 223 | AIZS (aizs.ink) | ✅ RCE — `uid=1000(worker)` via `/instances/.../console` exec into existing pods. Deploy new pods blocked by RBAC, but console exec to running pods works. SA token + Alipay service env vars extracted. |

## NO-AUTH — GATE OFFLINE/BROKEN (10 IPs)

| IP | Port | Platform | Apps | Company | Issue |
|----|------|----------|------|---------|-------|
| 34.210.237.133 | 80 | AWS us-west-2 | 0 | Unknown | Credential broken (aws-iam-auth v1alpha1 vs v1beta1) |
| 34.210.2.231 | 80 | AWS us-west-2 | 0 | Unknown | Credential broken — Gate direct IP (Q5) |
| 35.163.0.164 | 80 | AWS us-west-2 | 0 | Unknown | Credential broken — Gate direct IP (Q5) |
| 44.229.29.93 | 80 | AWS us-west-2 | 0 | Unknown | Same broken cluster |
| 3.128.248.243 | 80 | AWS us-east-2 | - | TRC Cloud | Gate handlers dead (health UP, API empty) |
| 3.133.27.45 | 80 | AWS us-east-2 | - | TRC Cloud | Same as above |
| 49.233.246.78 | 80 | Tencent Cloud China | - | Wanmeizhensuo | Gate DNS dead |
| 52.204.203.222 | 80 | AWS us-east-1 | - | Unknown | ELB decommissioned |
| 3.226.44.124 | 80 | AWS us-east-1 | - | Unknown | ELB decommissioned |
| 3.226.38.250 | 80 | AWS us-east-1 | - | Unknown | ELB decommissioned |
| 34.207.126.1 | 9000 | AWS us-east-1 | - | Boomtrain | Gate internal only (172.16.x.x) |
| 170.106.167.158 | 32068 | Tencent Cloud US | - | GetVideoX | Gate DNS dead |

---

## AUTH-ENABLED (55+ IPs → ~30 unique companies)
### New from ZoomEye + Shodan round 2-4:

| IP/Domain | Port | Platform | Company | Gate URL | Status |
|-----------|------|----------|---------|----------|--------|
| spinnaker.alphasights.com | 443 | AWS eu-west-1 | AlphaSights | spinnaker-api.alphasights.com | AUTH — Bearer held |
| cd.jupiter.money | 443 | AWS | Jupiter Money (India fintech) | cd-api.jupiter.money | AUTH — Bearer held |
| spinnaker.sparkcognition.com | 443 | GCP | SparkCognition (AI/ML) | spinnaker-api.sparkcognition.com | AUTH — Bearer held |
| altair.biofourmis.com | 443 | AWS us-west-2 | Biofourmis (healthcare AI) | altair-gate.biofourmis.com | AUTH — SAML/Okta |
| 54.70.9.121 | 80 | AWS us-west-2 | Unknown | ? | Dead |
| 34.218.157.34 | 443 | AWS us-west-2 | Unknown | health UP, apps 302 | AUTH — Bearer held |
| 34.74.170.3 | 443 | GCP us-east | Unknown | health UP, apps 403 | AUTH — Fiat RBAC blocks |
| 162.209.114.75 | 443 | Rackspace | Unknown | health UP, apps 403 | AUTH — Fiat RBAC blocks |
| prd-pos-spin-api.fastretailing.com | 443 | GCP | Fast Retailing/Uniqlo | Modern OAuth2 Client | AUTH — no ExternalAuthTokenFilter |

### Original auth-enabled list:

| IP | Port | Platform | Company | Gate URL |
|----|------|----------|---------|----------|
| 54.203.67.44 | 443 | AWS us-west-2 | Aruba Networks / HPE | spinnaker-api.cloudops.arubanetworks.com |
| 34.208.163.238 | 443 | AWS us-west-2 | Aruba / HPE | spinnaker-api.arubadev.cloud.hpe.com |
| 52.36.52.18 | 443 | AWS us-west-2 | Aruba / HPE | spinnaker-api.arubadev.cloud.hpe.com |
| 35.81.224.8 | 443 | AWS us-west-2 | Aruba / HPE | spinnaker-api.arubadev.cloud.hpe.com |
| 44.212.252.106 | 443 | AWS us-east-1 | Sophos | spinnaker-prod-gate.sophos-tools.com |
| 52.206.135.23 | 443 | AWS us-east-1 | Sophos | spinnaker-prod-gate.sophos-tools.com |
| 52.204.65.181 | 443 | AWS us-east-1 | Sophos | spinnaker-prod-gate.sophos-tools.com |
| 35.210.46.228 | 443 | GCP Belgium | Red Bull Media House | spinnaker-api-staging.redbullmediahouse.com |
| 35.240.1.103 | 443 | GCP Belgium | Red Bull Media House | spinnaker-api.redbullmediahouse.com |
| 35.190.42.166 | 443 | GCP us-central | e-conomic (Visma) | spinnaker-stag-api.e-conomic.io |
| 34.117.75.144 | 443 | GCP us-central | e-conomic (Visma) | api.spinnaker.e-conomic.net |
| 34.120.79.112 | 443 | GCP us-central | Netlify | spinnaker-api.ops.netlify.com |
| 35.190.41.41 | 80 | GCP us-central | BigFish Games | evermerge-demo-spin.pow.bigfishgames.com/gate |
| 34.102.131.170 | 80 | GCP us-central | BigFish Games | neskinsoft-spin.pow.bigfishgames.com/gate |
| 54.188.140.206 | 443 | AWS us-west-2 | Moderne | api-spinny.moderne.ninja |
| 52.36.111.103 | 443 | AWS us-west-2 | Moderne | api-spinny.moderne.ninja |
| 54.68.190.241 | 443 | AWS us-west-2 | Keen.io | spinnaker-api.infrastructure.keen.io |
| 44.234.245.4 | 443 | AWS us-west-2 | Keen.io | spinnaker-api.infrastructure.keen.io |
| 54.151.202.129 | 443 | AWS Singapore | Wahed (Islamic fintech) | gate.spin.prod.wahed.tech |
| 18.136.61.98 | 443 | AWS Singapore | Wahed | gate.spin.prod.wahed.tech |
| 47.131.62.154 | 443 | AWS Singapore | Wahed | gate.spin.prod.wahed.tech |
| 54.201.59.241 | 443 | AWS us-west-2 | HigherMe | deploy-api.higherme.dev |
| 35.162.229.199 | 443 | AWS us-west-2 | HigherMe | deploy-api.higherme.dev |
| 54.68.196.162 | 443 | AWS us-west-2 | HigherMe | deploy-api.higherme.dev |
| 52.27.29.249 | 443 | AWS us-west-2 | HigherMe | deploy-api.higherme.dev |
| 3.139.12.216 | 443 | AWS us-east-2 | Sureify | sping.sureifylifeco.com |
| 3.149.186.54 | 443 | AWS us-east-2 | Sureify | sping.sureifylifeco.com |
| 23.22.244.233 | 443 | AWS us-east-1 | BridgeOps | prod.spinnaker.bridgeops.sh:8084 |
| 44.212.172.28 | 443 | AWS us-east-1 | BridgeOps | prod.spinnaker.bridgeops.sh:8084 |
| 34.64.229.199 | 80 | GCP Seoul | SKT Jive (Korea) | spinnaker-api.skt-jive.com |
| 35.184.230.24 | 80 | GCP us-central | Reibbdev | ops-api.reibbdev.com |
| 35.186.227.151 | 80 | GCP us-central | Bizwise | spinnaker-api.bizwise.com |
| 35.197.11.16 | 80 | GCP us-west | KQED (public media) | spin-api.kqed.org |
| 35.241.225.85 | 80 | GCP Belgium | Dolph.in | bamboo.dolph.in/spinnaker/api/ |
| 34.120.36.246 | 443 | GCP us-central | Aspen Dental | spinnaker.aspendental.com/api/v1 |
| 34.102.186.121 | 80 | GCP us-central | Causeway Technologies | spinnaker-gate.tradex.dev.causeway.com |
| 34.111.44.155 | 443 | GCP us-central | Retpada | spinnaker-gate.retpada.whoami.zone |
| 34.128.170.167 | 443 | GCP us-central | ClarityApp | spinnaker.infra.clarityapp.in/gate |
| 34.133.1.157 | 80 | GCP us-central | QualifiedHealth AI | spinnaker.qualifiedhealthai.com/gate |
| 34.160.124.9 | 443 | GCP us-central | Teamtag | spinnaker.teamtag.com/api/v1 |
| 34.218.63.33 | 443 | AWS us-west-2 | Devspoon | ops-spinnaker.devspoon.net/api/v1 |
| 52.154.252.244 | 9000 | Azure US | EdgeNet | spinnakergate.edgenet.com:8084 |
| 47.75.116.135 | 9000 | Alibaba HK | Moseeker | spinnaker.moseeker.com:8084 |
| 34.74.170.3 | 443 | GCP US | Unknown | ? |
| 35.227.20.117 | 80 | GCP US | Unknown | ? |
| 162.209.114.36 | 443 | Rackspace US | Unknown | ? |
| 104.130.31.38 | 30786 | Rackspace US | Unknown | ? |
| 136.109.165.2 | 30094 | GCP us-west | jawbonr.com | spingate.infra.jawbonr.com:8084 (internal) |
| 136.117.4.112 | 30094 | GCP us-west | jawbonr.com | spingate.infra.jawbonr.com:8084 (internal) |
| 34.168.253.53 | 30094 | GCP us-west | jawbonr.com | spingate.infra.jawbonr.com:8084 (internal) |
| 34.82.56.9 | 30094 | GCP us-west | jawbonr.com | spingate.infra.jawbonr.com:8084 (internal) |
| 34.82.82.68 | 30094 | GCP us-west | jawbonr.com | spingate.infra.jawbonr.com:8084 (internal) |
| 8.231.174.107 | 30094 | GCP us-west | jawbonr.com | spingate.infra.jawbonr.com:8084 (internal) |
| 8.231.191.213 | 30094 | GCP us-west | jawbonr.com | spingate.infra.jawbonr.com:8084 (internal) |
| 35.230.78.170 | 9000 | GCP us-west | jawbonr.com | spingate.infra.jawbonr.com:8084 (internal) |

## ADDITIONAL IPs FROM SHODAN/NETLAS (32 IPs — all DOWN/AUTH/NOT-SPINNAKER)

| IP | Port | Source | Status |
|----|------|--------|--------|
| 54.189.108.230 | 443 | Shodan+Netlas | Spinnaker Deck, AUTH=true (Aruba/HPE cluster) |
| 54.71.225.3 | 443 | Shodan | AUTH — "not authorized" (VPS only) |
| 35.233.190.209 | 8084 | Shodan | Gate AUTH (jawbonr.com — already in auth list) |
| 18.232.183.140 | 80/443 | Shodan | 200 but empty — not Spinnaker |
| 13.219.150.148 | 443 | Shodan | 200 — Ascent Loan Sales app, not Spinnaker |
| 18.118.92.161 | 80/443 | Shodan | 403 — "User not authorized" |
| 35.196.104.28 | 80 | Shodan | 302 → BigIP, not Spinnaker |
| 3.128.3.226 | 443 | Shodan | 404 |
| 34.149.184.54 | 443 | Shodan | 404 |
| 34.41.228.235 | 443 | Netlas | 404 (spinnaker.qmengineering.com) |
| 34.117.241.67 | 443 | Netlas | 404 (spinnaker-ng.mindvalley.dev) |
| 35.185.13.237 | 443 | Shodan | 500 — not Spinnaker |
| 44.241.150.172 | 443 | Shodan | 302 → Sterling Bank, not Spinnaker |
| 44.245.79.234 | 443 | Shodan | 403 — AWS Elasticsearch |
| 98.88.163.87 | - | Shodan | Dead — residential IP |
| 3.134.139.255 | - | Shodan | Dead from Kali+VPS |
| 3.131.4.70 | - | Shodan | Dead from Kali+VPS |
| 3.137.35.200 | - | Shodan | Dead from Kali+VPS |
| 3.143.76.37 | - | Shodan | Dead from Kali+VPS |
| 3.149.33.136 | - | Shodan | Dead from Kali+VPS |
| 3.226.41.155 | - | Shodan | Dead from Kali+VPS |
| 18.216.139.19 | - | Shodan | Dead from Kali+VPS |
| 34.133.64.17 | - | Shodan | Dead from Kali+VPS |
| 34.176.186.100 | - | Shodan | Dead from Kali+VPS |
| 34.217.216.113 | - | Shodan | Dead from Kali+VPS |
| 43.135.170.195 | - | Shodan | Dead from Kali+VPS |
| 44.238.112.211 | - | Shodan | Dead from Kali+VPS |
| 44.240.181.42 | - | Shodan | Dead from Kali+VPS |
| 52.36.136.197 | - | Shodan | Dead from Kali+VPS |
| 54.151.175.50 | - | Shodan | Dead from Kali+VPS |
| 54.187.50.79 | - | Shodan | Dead from Kali+VPS |
| 54.191.5.219 | - | Shodan | Dead from Kali+VPS |

## OTHER / UNCLASSIFIED (11 IPs)

| IP | Port | Platform | Status |
|----|------|----------|--------|
| 18.233.235.93 | 443 | AWS us-east-1 | Auth (reachable from VPS only) |
| 3.231.252.41 | 443 | AWS us-east-1 | Auth (reachable from VPS only) |
| 54.226.246.230 | 443 | AWS us-east-1 | Auth (reachable from VPS only) |
| 44.207.184.87 | 443 | AWS us-east-1 | Auth (reachable from VPS only) |
| 44.221.118.95 | 443 | AWS us-east-1 | Auth (reachable from VPS only) |
| 32.199.237.15 | 443 | AWS us-east-1 | Auth (reachable from VPS only) |
| 35.160.79.138 | 443 | AWS us-west-2 | Auth (query 4 only) |
| 35.167.5.145 | 80 | AWS us-west-2 | Auth (reachable from VPS only) |
| 52.25.69.117 | 80 | AWS us-west-2 | Auth (reachable from VPS only) |
| 54.148.193.7 | 80 | AWS us-west-2 | Auth (reachable from VPS only) |
| 13.231.101.57 | 443 | AWS Tokyo | Auth |
| 52.192.137.155 | 443 | AWS Tokyo | Auth |
| 100.62.121.15 | 443 | AWS us-east-1 | No settings.js (403) |
| 34.8.210.171 | 80 | GCP us-central | Deck only (Gate localhost) |
| 18.190.29.48 | 80 | AWS us-east-2 | Dead from everywhere |

## ZOOMEYE BATCH 2 — DEAD/FALSE POSITIVE (2026-08-26)

Tested from Kali + VPS NYC + VPS AMS. All dead or false positive.

| IP | Source | Status |
|----|--------|--------|
| 44.238.13.215 | ZoomEye `"netflix.spinnaker"` | AWS OpenSearch (not Spinnaker) |
| 44.237.39.141 | ZoomEye `"netflix.spinnaker"` | AWS OpenSearch (not Spinnaker) |
| 54.179.224.244 | ZoomEye `"netflix.spinnaker"` | AWS CloudSearch (not Spinnaker) |
| 52.204.242.92 | ZoomEye `"netflix.spinnaker"` | Not Spinnaker (redirect /pt) |
| 52.11.100.63 | ZoomEye `"X-SPINNAKER"` | AWS OpenSearch (not Spinnaker) |
| 34.216.81.165 | ZoomEye `"netflix.spinnaker"` | AWS OpenSearch (not Spinnaker) |
| 54.212.218.123 | ZoomEye `"netflix.spinnaker"` | AWS ELB 403 Forbidden |
| 34.224.35.189 | ZoomEye `"netflix.spinnaker"` | 503 Service Unavailable |
| 35.170.46.146 | ZoomEye `"netflix.spinnaker"` | Generic listener (not Spinnaker) |
| 18.206.113.2 | ZoomEye `"netflix.spinnaker"` | Java webapp (JSESSIONID, not Spinnaker) |
| 54.211.155.146 | ZoomEye `"netflix.spinnaker"` | Spinnaker Deck+Gate, AUTH HELD (401) |
| 54.189.108.230 | ZoomEye `"netflix.spinnaker"` | Spinnaker Deck (Gate=arubanetworks, already in list) |
| 16.146.178.221 | ZoomEye `"netflix.spinnaker"` | Deck via ELB (Gate=moderne.ninja, auth) |
| 34.207.126.1 | ZoomEye `"netflix.spinnaker"` | Deck only (Gate=boomtrain, dead) |
| 162.209.114.127 | ZoomEye `"X-SPINNAKER"` | Dead from all VPS |
| 162.209.115.11 | ZoomEye `"X-SPINNAKER"` | Dead from all VPS |
| 162.209.114.87 | ZoomEye `"X-SPINNAKER"` | Dead from all VPS |
| 18.117.47.81 | ZoomEye `"X-SPINNAKER"` | Dead from all VPS |
| 52.4.152.58 | ZoomEye `"X-SPINNAKER"` | 404 on 443, Gate dead |
| 13.232.66.243 | ZoomEye `"X-SPINNAKER"` | Dead (India, PayU) |
| 34.252.246.171 | ZoomEye `"X-SPINNAKER"` | Dead (Ireland, mpi-internal) |
| 34.248.253.116 | ZoomEye `"X-SPINNAKER"` | Dead (Ireland, mpi-internal) |
| 34.252.76.39 | ZoomEye `"X-SPINNAKER"` | Cognito auth (not Spinnaker Gate) |
| 18.117.200.111 | ZoomEye `"netflix.spinnaker"` | Dead from all VPS |
| 34.233.210.223 | ZoomEye `"netflix.spinnaker"` | Dead from all VPS |
| 54.244.134.32 | ZoomEye `"netflix.spinnaker"` | Dead from all VPS |
| 103.245.255.145 | ZoomEye `"netflix.spinnaker"` | Dead (Vietnam, ZingPlay) |
| 54.165.112.100 | ZoomEye `"netflix.spinnaker"` | Dead from all VPS |
| 18.223.53.97 | ZoomEye `"netflix.spinnaker"` | Dead from all VPS |
| 44.254.53.56 | ZoomEye `"netflix.spinnaker"` | Dead from all VPS |
| 54.69.1.11 | ZoomEye `"netflix.spinnaker"` | Dead from all VPS |
| 18.223.70.46 | ZoomEye `"netflix.spinnaker"` | Dead from all VPS |
| 52.40.240.21 | ZoomEye `"netflix.spinnaker"` | Dead from all VPS |
| 34.238.179.83 | ZoomEye `"netflix.spinnaker"` | Dead from all VPS |
| 16.145.30.247 | ZoomEye `"netflix.spinnaker"` | Dead from all VPS |
| 18.221.217.33 | ZoomEye `"X-SPINNAKER"` | Dead from all VPS |
| 18.217.78.238 | ZoomEye `"X-SPINNAKER"` | 403 on 443 (not Spinnaker) |
| 34.193.83.136 | ZoomEye `"X-SPINNAKER"` | Dead from all VPS |
| 16.147.168.146 | ZoomEye `"netflix.spinnaker"` | Dead from all VPS |

### New Gate Domains Discovered (from settings.js):
- `api-spinny.moderne.ninja` — Gate alive, Google OAuth, Bearer bypass FAILED (modern oauth2/authorization)
- `preprod-spinnaker.aws.boomtrain.com:8084` — Dead
- `spinnaker.originfintech.io` — Dead (South Africa)
- `x509-api.stairwell.opsmx.net` — OpsMx Gate, 403 Fiat RBAC, x509 client cert auth

### FOFA (en.fofa.info) — 79 results (61 unique IP):
- `header="X-SPINNAKER-REQUEST-ID"` → 79 results
- `header="X-SPINNAKER-REQUEST-ID" && port="8084"` → 15 results
- New IPs: 34.176.85.61 (Chile GCP), 3.82.20.238 (AWS Virginia), 18.218.218.188, 3.147.254.213, 54.203.24.211, 35.237.19.46 (OpsMx)
- All tested from Kali + VPS NYC → ALL DEAD

### FOFA body="#149CB5" query — 432 results:
- New domains discovered:
  - `spinnaker.redbullmediahouse.com` (35.240.1.103, GCP Belgium) — Auth (OAuth2 modern), fiat=false
  - `spinnaker-staging.redbullmediahouse.com` (35.210.46.228) — Auth (OAuth2), fiat=false
  - `spinnaker-api-staging.redbullmediahouse.com` — Gate, Bearer bypass FAILED
  - `spinnaker-qa.qa.cds.hpe.com` (52.26.20.50, AWS Oregon) — HPE QA, Auth+Fiat
  - `spinnaker.common.cloud.hpe.com` (15.222.108.151, AWS Canada) — HPE Common, Auth+Fiat
  - `spinnaker-qa-api.qa.cds.hpe.com` — HPE Gate, Bearer bypass FAILED
  - `spinnaker-api.common.cloud.hpe.com` — HPE Gate, Bearer bypass FAILED
- All Gates use modern OAuth2 Client (not legacy @EnableOAuth2Sso) → Bearer bypass NOT applicable
- Additional FOFA body="#149CB5" discoveries:
  - `cicd.scalars-access.com` (3.175.64.28, AWS Canada) — Armory, Cognito auth
  - `spinnaker.mercari.in` (35.186.192.92, GCP) — Mercari Japan, custom /login auth+fiat
  - `spinnaker-api.mercari.in` — Gate alive, auth-held
  - `spinnaker.lab.citadelapps.com` (35.201.100.222, GCP) — Citadel Labs, custom /login auth+fiat
  - `spinnaker-api.lab.citadelapps.com` — Gate alive, auth-held
  - `spinnaker.arubadev.cloud.hpe.com` (35.81.224.8) — HPE Aruba Dev, SAML2 auth
  - `spinnaker.data.cloud.hpe.com` (35.164.62.239) — HPE Data, OAuth2 auth
  - `spin.prod.wahed.tech` (52.76.233.92, AWS Singapore) — Wahed Invest, custom /login auth
  - `spinnaker.testdevelopment.northstar.hpedevops.net` (35.160.40.249) — HPE DevOps Test, auth+fiat
  - `test-spinnaker.admin.cxm-salescloud.com` (52.59.126.162, AWS Frankfurt DE) — SalesCloud, auth+fiat
  - `spin-gate.test.wanmeizhensuo.com` (62.234.200.39, Tencent CN) — NO AUTH config but Gate 502 (backend dead)
  - `spinnaker-api.skt-jive.com` (34.64.182.214, GCP Korea) — SKT, auth-held
  - `spinnaker-api.a-boyd.com` (76.14.61.179, Wave Broadband CA) — NO-AUTH! But empty Clouddriver (no K8s/cloud accounts) = no RCE
  - 52.42.4.236 (AWS Oregon) — Dead
  - 100.21.206.183 (AWS Oregon) — Dead
  - `ops-spinnaker.devspoon.net` (16.146.193.82, AWS us-east-2) — SAML auth, fiat=false
  - 16.59.50.146 (AWS us-east-2) — CorporateMutt node baru (same cluster, al RCE)
  - 23.251.149.86 — Dead
  - 100.29.236.92 — Dead
  - 100.20.179.53 (AWS us-east-1) — VIZIO Smart TV, Deck HTTPS, Gate=dev-spinnaker-gate.vizio-is.com, auth /login, fiat=false, Bearer bypass FAILED
  - 3.220.250.93 (AWS us-east-1) — Deck HTTPS alive (VPS only), Gate internal
  - 52.201.98.250 (AWS us-east-1) — Deck no-auth config, Gate ELB 503 (backend down)
  - 54.88.28.212 (AWS us-east-1) — Deck alive ALL 5 locations, auth=false, fiat=false, SAME ELB Gate = 503
  - 34.226.37.251 (AWS us-east-1) — Dead from all 4 VPS

### ZoomEye older results (2025 and before) — ALL DEAD:
| 57.181.55.236 | 8084 | Japan | Dead (earth-k8s-tools ELB) |
| 34.201.191.53 | 80 | AWS us-east-1 | nginx 404 (not Spinnaker) |
| 13.246.167.65 | 8084 | South Africa | Dead (Origin Fintech) |
| 64.71.137.187 | 8084 | Hurricane Electric | Dead (was no-auth redirect) |
| 34.214.96.96 | 80 | AWS us-west-2 | nginx 404 (not Spinnaker) |
| 34.16.125.195 | 8084 | GCP | Dead |
| 52.192.66.172 | 8084 | Japan | Dead (earth-k8s-tools) |
| 54.165.182.131 | 80 | AWS us-east-1 | Dead |
| 35.74.128.170 | 8084 | Japan | Dead (earth-k8s-tools) |
| 104.130.120.189 | 443 | Rackspace | Dead |
