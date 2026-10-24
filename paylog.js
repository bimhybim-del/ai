const mysql = require("mysql2/promise");
(async () => {
  const c = await mysql.createConnection({
    host: "aether.mysql.prod.yoi.local",
    user: "aether-svc",
    password: "f9pXQYRxALywyVIw",
    database: "yoi",
    connectTimeout: 10000
  });

  // Get recent payment disbursement logs — find valid transaction_ids
  console.log("=== PAYMENT DISBURSEMENT LOGS ===");
  const [logs] = await c.query(`
    SELECT id, endpoint_path, status_code, full_url, 
           LEFT(request_data, 500) as req, 
           LEFT(response_data, 500) as resp,
           created_at
    FROM conduit_apirequestlog 
    WHERE service_name='payment' 
      AND (endpoint_path LIKE '%disburs%' OR endpoint_path LIKE '%ibft%' OR endpoint_path LIKE '%transfer%')
    ORDER BY id DESC LIMIT 10
  `);
  
  logs.forEach(r => {
    console.log(`\nID:${r.id} | ${r.endpoint_path} | HTTP:${r.status_code} | ${r.created_at}`);
    if (r.req) console.log(`  REQ: ${r.req}`);
    if (r.resp) console.log(`  RESP: ${String(r.resp).slice(0,200)}`);
  });

  // Search for any request with claim_id or transaction_id
  console.log("\n=== CLAIM/TRANSACTION IDS ===");
  const [claims] = await c.query(`
    SELECT id, endpoint_path, request_data, created_at
    FROM conduit_apirequestlog 
    WHERE service_name='payment' 
      AND (request_data LIKE '%claim_id%' OR request_data LIKE '%transaction_id%')
    ORDER BY id DESC LIMIT 5
  `);
  
  claims.forEach(r => {
    console.log(`\nID:${r.id} | ${r.endpoint_path} | ${r.created_at}`);
    console.log(`  DATA: ${String(r.request_data).slice(0,500)}`);
  });

  // Count total payment logs
  const [cnt] = await c.query("SELECT COUNT(*) as c FROM conduit_apirequestlog WHERE service_name='payment'");
  console.log(`\nTotal payment logs: ${cnt[0].c}`);

  await c.end();
})().catch(e => console.log("ERR:", e.message));
