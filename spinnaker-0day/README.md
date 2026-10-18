# Spinnaker Gate 0-Day Security Research — Source Code Audit Package

## OBJECTIVE FOR MYTHOS
Find **NEW authentication bypass vulnerabilities** (pre-auth, zero-click) or **RCE chains** in Spinnaker Gate that have NOT been found in our previous 320+ technique audit.

## WHAT IS SPINNAKER
Netflix Spinnaker is a multi-cloud continuous delivery platform. **Gate** is the API gateway — ALL user requests go through Gate. If Gate auth is bypassed → full control of deployments → RCE on cloud infrastructure (K8s, AWS, GCP, Azure).

## ARCHITECTURE
```
Client → [Proxy/WAF] → Gate (:8084) → Spring Security Filter Chain
                                          ↓
                                   Controllers (REST API)
                                          ↓
                        Clouddriver(:7002) | Orca(:8083) | Echo(:8089) | Front50(:8080) | Fiat(:7003)
```

## TECHNOLOGY STACK
- Java 17, Spring Boot 2.7.18, Spring Security 5.7.11
- Embedded Tomcat 9.0.83 with StrictHttpFirewall
- Kotlin 1.6.21, Groovy 3.0.19
- Jackson 2.13.5 (NO DefaultTyping)
- Spring Session Redis, OAuth2 (legacy @EnableOAuth2Sso)
- Auth: OAuth2 (GitHub/Google/Azure AD/Okta/GitLab), SAML, LDAP, X.509, Basic

## DIRECTORY STRUCTURE
```
gate-security/     → Gate API Gateway source (363 files) — AUTH CONFIG, CONTROLLERS, FILTERS
kork-security/     → Kork shared library (760 files) — AUTH FILTERS, SpEL, INTERCEPTORS
echo-security/     → Echo event engine (369 files) — WEBHOOKS, NOTIFICATIONS, SpEL EVAL
orca-security/     → Orca pipeline engine (1968 files) — SpEL EVALUATION, PIPELINE EXECUTION
front50-security/  → Front50 persistence (287 files) — PIPELINE/APP STORAGE, @PreAuthorize gaps
spring-oauth2/     → Spring Security OAuth2 framework (2197 files) — OAUTH2 FLOW, TOKEN HANDLING
exploits/          → Working exploit scripts (7 files) — PROVEN PoCs
context/           → Research notes + target list — WHAT'S ALREADY BEEN TRIED
```

## CRITICAL FILES TO AUDIT FIRST (Priority Order)

### 1. Gate Auth Configuration
- `gate-security/gate-core/src/main/java/com/netflix/spinnaker/gate/config/AuthConfig.java`
  - Spring Security HttpSecurity configuration
  - PermitAll endpoints: /webhooks/**, /health, /auth/user, /plugins/deck/**, /notifications/callbacks/**
  - Webhook auth default: `security.webhooks.default-auth-enabled=false`

### 2. Authentication Filters (execution order matters!)
- `kork-security/kork-web/src/main/java/com/netflix/spinnaker/kork/web/interceptors/AuthenticatedRequestFilter.groovy`
  - Extracts X-SPINNAKER-USER header → sets identity for downstream calls
  - On permitAll endpoints (no Spring Security principal) → FALLS BACK TO HEADER VALUE
  
- `gate-security/gate-oauth2/src/main/java/com/netflix/spinnaker/gate/security/oauth2/ExternalAuthTokenFilter.java`
  - Bearer token extraction from Authorization header
  - Token validated against OAuth provider's userInfoUri

- `gate-security/gate-core/src/main/java/com/netflix/spinnaker/gate/security/iap/IapAuthenticationFilter.java`
  - Google IAP JWT verification — CATCHES ALL EXCEPTIONS and continues (fail-open!)
  - Session signature caching — cached JWT signature replayed without revalidation

### 3. OAuth2 Flow (Framework Bug Location)
- `spring-oauth2/spring-security-oauth/spring-security-oauth2/src/main/java/org/springframework/security/oauth2/client/token/grant/code/AuthorizationCodeAccessTokenProvider.java`
  - Line 174: `resource.getRedirectUri(request)` reads redirect_uri FROM HTTP REQUEST
  
- `spring-oauth2/spring-security-oauth/spring-security-oauth2/src/main/java/org/springframework/security/oauth2/client/resource/AbstractRedirectResourceDetails.java`
  - `getRedirectUri()`: user-supplied redirect_uri OVERRIDES server config

### 4. SpEL Evaluation (RCE Vector)
- `orca-security/orca-core/src/main/java/com/netflix/spinnaker/orca/pipeline/expressions/PipelineExpressionEvaluator.java`
- `orca-security/orca-core/src/main/java/com/netflix/spinnaker/orca/pipeline/util/UrlExpressionFunctionProvider.java`
  - `#fromUrl()` function → HTTP GET to arbitrary URL (SSRF from pipeline SpEL)
  
- `echo-security/echo-pipelinetriggers/src/main/java/com/netflix/spinnaker/echo/pipelinetriggers/postprocessors/ExpectedArtifactExpressionEvaluationPostProcessor.java`
  - Uses UNSANDBOXED StandardEvaluationContext (no AllowListTypeLocator!)
  - CVE-2026-32613 — but audit for ADDITIONAL unsandboxed eval locations

### 5. Multi-Connector Auth Bypass
- `gate-security/gate-core/src/main/java/com/netflix/spinnaker/gate/security/MultiAuthSupport.java`
  - When `server.ssl.enabled=true` AND `default.api-port > 0`:
  - Security chain ONLY matches default port
  - Requests to apiPort SKIP OAuth2/SAML filter chain entirely

### 6. Webhook Handlers (Pre-Auth Attack Surface)
- `gate-security/gate-web/src/main/java/com/netflix/spinnaker/gate/controllers/WebhookController.groovy`
  - No auth required (permitAll)
  - Forwards to Echo with X-SPINNAKER-USER header (identity injection)
  
- `echo-security/echo-webhooks/src/main/java/com/netflix/spinnaker/echo/artifacts/` (all files)
  - Artifact extractors parse webhook payload → potential deserialization/injection

### 7. Session Management
- `spring-oauth2/spring-security-core/` (Session-related files)
  - Spring Session Redis: if attacker has Redis access → inject auth context → full bypass

## 12 CVEs ALREADY DISCOVERED (Do NOT re-report these)

| ID | Finding | Status |
|----|---------|--------|
| F-10 | X-SPINNAKER-USER identity injection on permitAll endpoints | Confirmed |
| F-19/33/51 | OAuth2 redirect_uri override (spring-security-oauth2 framework bug) | Confirmed 14 targets |
| F-21 | ExternalAuthTokenFilter Bearer token injection bypass | 5 targets RCE'd |
| F-34 | GitHub org check skip when org not configured | Lab proven |
| F-35 | Content-type confusion (application/json vs form) → Front50 pre-auth | Blocked by enum |
| F-36 | Application name enumeration via 403/500 differential | Info disclosure |
| F-37 | Front50 missing @PreAuthorize on several controllers | Not exposed externally |
| F-38 | Echo callback SSRF + identity injection via notification handler | Needs Slack HMAC |
| F-39 | Azure AD Device Code Flow auth bypass | Needs user interaction |
| F-40 | GitHub org check fail-open on HTTP exception | Lab proven |
| F-41 | X.509 CN parsing bypass (CVE-2026-47838) | Lab proven |
| F-NEW | Spring Session Context Injection via Redis | Lab proven |

## WHAT HAS BEEN EXHAUSTIVELY TESTED (330+ techniques — DO NOT REPEAT)

### Path/URL Level (EXHAUSTED)
- ALL path traversal variants (../, ..;/, %2e%2e, double encode, unicode, overlong UTF-8)
- StrictHttpFirewall blocks: semicolons, encoded slashes, dot segments, backslashes, null bytes
- Tomcat CoyoteAdapter normalizes ALL paths before Spring Security
- Case sensitivity, trailing slash, file extensions (.json, .xml) — all caught by /** auth

### HTTP Protocol Level (EXHAUSTED)
- HTTP method bypass (GET/POST/PUT/DELETE/PATCH/OPTIONS/HEAD/TRACE/CONNECT)
- HTTP/1.0, HTTP/2 h2c upgrade, HTTP/2 PUSH_PROMISE
- Request smuggling CL.TE, TE.CL, CL.0, TE.TE — all blocked by proxy/WAF
- WebDAV methods (PROPFIND, SEARCH, COPY) — 500 rejected
- X-HTTP-Method-Override, _method — no effect

### Auth Level (EXHAUSTED)
- JWT alg:none, HS256 empty key — rejected
- Session prediction (UUID v4 = 2^122 entropy)
- Session fixation (changeSessionId on auth)
- Cookie manipulation, CSRF token abuse
- Cross-provider token injection (Google→GitHub) — provider validates
- OAuth2 state brute force (36-bit SecureRandom, session-bound)
- Default credentials — OAuth2 redirect (no form login)

### Deserialization (EXHAUSTED)
- Jackson @class/@type — NO DefaultTyping enabled
- SnakeYAML !! tags — Jackson wraps, strips tags
- CloudEvents data_base64 — Jackson parse, safe
- XML XXE — expects JSON
- Java serialization — Spring Session uses UUID not serialized objects

### Infrastructure (EXHAUSTED)
- Port scan all targets: Orca(8083), Echo(8089), Clouddriver(7002), Front50(8080) — ALL CLOSED
- Redis(6379), Elasticsearch(9200), MongoDB(27017), JMX — ALL CLOSED
- ZERO Spinnaker internal services exposed globally (Censys confirmed)
- Actuator endpoints — ALL behind auth (302)

## WHAT MYTHOS SHOULD FOCUS ON (Unexplored Areas)

### 1. Spring Security 5.7.11 Framework-Level Bugs
- Differential path matching between FilterChainProxy and DispatcherServlet
- Edge cases in AntPathRequestMatcher when patterns contain wildcards
- FilterChainProxy re-entry behavior on FORWARD/ERROR dispatches
- SecurityContextRepository edge cases during async/streaming requests
- DelegatingFilterProxy ordering edge cases with multiple chains

### 2. Tomcat 9.0.83 Request Parser Edge Cases
- CoyoteAdapter path normalization — any chars that survive normalization differently
- HTTP/2 frame handling — header continuation, HPACK decoding edge cases
- Connector threading model — race conditions during request parsing
- Request recycling — stale data from previous request surviving cleanup

### 3. Spring MVC DispatcherServlet Routing
- Content negotiation edge cases (Accept header → different handler)
- HandlerMapping resolution order when multiple mappings match
- @RequestMapping vs @GetMapping behavior differences
- PathPattern vs AntPathMatcher behavior differences
- Error dispatch flow through /error endpoint

### 4. Groovy/Kotlin Runtime Edge Cases
- Groovy metaclass manipulation via crafted input
- Kotlin companion object initialization race
- GString interpolation in Groovy controllers

### 5. Inter-Service Communication
- How Gate→Echo→Orca propagates identity (X-SPINNAKER-* headers)
- Whether webhook payload can influence pipeline trigger matching in unexpected ways
- Whether artifact extractors (BitBucket, GitHub, GitLab, Docker, Helm) have deserialization issues
- Whether CDEvents/CloudEvents handler has type confusion bugs

### 6. Configuration-Dependent Vulnerabilities
- What happens when BOTH OAuth2 AND SAML are configured simultaneously
- What happens when x509 is enabled WITHOUT proper CA configuration
- What happens when Fiat is disabled (permission checks skipped entirely)
- What happens when `services.deck.base-url` is misconfigured (open redirect chain)

### 7. Race Conditions
- OAuth2 callback processing — window between code exchange and session creation
- Concurrent webhook processing — shared state corruption
- Spring Session Redis — read-modify-write race on session attributes
- FiatSessionFilter — permission check vs operation execution gap

### 8. Novel Deserialization Vectors
- ObjectMapperSubtypeConfigurer — dynamically registers Jackson subtypes
- ArtifactExtractor implementations — parse untrusted webhook payloads
- Pipeline template rendering — Jinja2 via Jinjava library
- SpEL expression evaluation in unexpected contexts (not just #fromUrl)

### 9. Dependency Chain Vulnerabilities
- Transitive dependencies with known CVEs but unexplored exploit paths
- commons-jxpath 1.3 (CVE-2022-41852) — is it actually reachable from user input?
- Velocity 2.2 — any template injection paths?
- springfox 3.0.0 — endpoint metadata leakage

### 10. Zero-Day in Spring Security OAuth2 (Legacy EOL)
- Already found redirect_uri override — are there MORE bugs in this EOL library?
- Token endpoint behavior with malformed requests
- Resource server token validation bypass
- Client credential grant type confusion
- Implicit flow token leakage via fragment handling

## LIVE TARGETS FOR VALIDATION
See `context/all-ips.md` for 18 auth-enabled and several no-auth Spinnaker instances.

## HOW TO USE THIS REPO
1. Start with `gate-security/` — this is the entry point for ALL requests
2. Trace the filter chain in `AuthConfig.java` → each filter in order
3. Focus on permitAll endpoints as attack surface
4. Look for path matching inconsistencies between Tomcat, Spring Security, and Spring MVC
5. Audit inter-service communication for identity injection/spoofing
6. Check every SpEL evaluation context for sandbox escapes
7. Use `context/notes.md` to understand what's been tried (avoid repeating 330+ failed techniques)
