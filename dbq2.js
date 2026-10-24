const mysql = require("mysql2/promise");
(async () => {
  const c = await mysql.createConnection({
    host: "payment-service.mysql.prod.yoi.local",
    user: "payment-service-svc",
    password: "OA1kyIEDllKsg8qZzMacHlgdJvxJiDP7",
    database: "payment_service_production",
    connectTimeout: 10000
  });
  
  // Get disbursements table columns
  const [cols] = await c.query("DESCRIBE disbursements");
  console.log("DISBURSEMENTS COLUMNS:");
  cols.forEach(r => console.log(r.Field, r.Type));
  
  // Get recent disbursements (last 5)
  const [recent] = await c.query("SELECT * FROM disbursements ORDER BY id DESC LIMIT 3");
  console.log("\nRECENT DISBURSEMENTS:");
  recent.forEach(r => console.log(JSON.stringify(r)));
  
  // Count total
  const [cnt] = await c.query("SELECT COUNT(*) as total FROM disbursements");
  console.log("\nTOTAL DISBURSEMENTS:", cnt[0].total);
  
  // Get inquiries schema
  const [icols] = await c.query("DESCRIBE inquiries");
  console.log("\nINQUIRIES COLUMNS:");
  icols.forEach(r => console.log(r.Field, r.Type));
  
  // Recent inquiries
  const [rinq] = await c.query("SELECT * FROM inquiries ORDER BY id DESC LIMIT 2");
  console.log("\nRECENT INQUIRIES:");
  rinq.forEach(r => console.log(JSON.stringify(r)));
  
  await c.end();
})().catch(e => console.log("ERR:", e.message));
