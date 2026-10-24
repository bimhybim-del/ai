const mysql = require("mysql2/promise");
(async () => {
  const c = await mysql.createConnection({
    host: "payment-service.mysql.prod.yoi.local",
    user: "payment-service-svc",
    password: "OA1kyIEDllKsg8qZzMacHlgdJvxJiDP7",
    database: "payment_service_production",
    connectTimeout: 10000
  });
  
  // Show tables
  const [tables] = await c.query("SHOW TABLES");
  console.log("TABLES:", tables.length);
  tables.forEach(r => console.log(Object.values(r)[0]));
  
  // Get recent disbursements
  try {
    const [disb] = await c.query("SELECT id,claim_id,amount,status,bank_code,created_at FROM disbursements ORDER BY id DESC LIMIT 5");
    console.log("\nRECENT DISBURSEMENTS:");
    disb.forEach(r => console.log(JSON.stringify(r)));
  } catch(e) {
    console.log("disbursements table error:", e.message);
    // Try find disbursement-like tables
    const [info] = await c.query("SELECT table_name FROM information_schema.tables WHERE table_schema='payment_service_production'");
    info.forEach(r => console.log(r.table_name));
  }
  
  await c.end();
})().catch(e => console.log("ERR:", e.message));
