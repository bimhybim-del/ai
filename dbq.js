const mysql = require("/app/node_modules/mysql2/promise");
(async () => {
  const c = await mysql.createConnection({
    host: "payment-service.mysql.prod.yoi.local",
    user: "payment-service-svc",
    password: "OA1kyIEDllKsg8qZzMacHlgdJvxJiDP7",
    database: "payment_service_production",
    connectTimeout: 10000
  });
  const [tables] = await c.query("SHOW TABLES");
  console.log("TABLES:", tables.length);
  tables.forEach(r => console.log(Object.values(r)[0]));
  
  // Find disbursement related tables
  const [info] = await c.query("SELECT table_name FROM information_schema.tables WHERE table_schema='payment_service_production' AND (table_name LIKE '%disburs%' OR table_name LIKE '%claim%' OR table_name LIKE '%payment%' OR table_name LIKE '%xendit%')");
  console.log("\nDISBURSEMENT-RELATED TABLES:");
  info.forEach(r => console.log(r.TABLE_NAME || r.table_name));
  
  await c.end();
})().catch(e => console.log("ERR:", e.message));
