const mysql = require("mysql2/promise");
(async () => {
  // Try both DB hosts
  const dbs = [
    {
      name: "TUGU_PROD",
      host: "prod-tugu-db.cqghqzfjfibt.ap-southeast-3.rds.amazonaws.com",
      user: "payment-svc", pass: "TXBisKJcBOWjWcZY6jJOTM7D7RfMba38",
      db: "payment_service_production"
    },
    {
      name: "ADB_PROD",
      host: "payment-service.mysql.prod.yoi.local",
      user: "payment-service-svc", pass: "OA1kyIEDllKsg8qZzMacHlgdJvxJiDP7",
      db: "payment_service_production"
    }
  ];
  
  for (const d of dbs) {
    try {
      const c = await mysql.createConnection({
        host: d.host, user: d.user, password: d.pass,
        database: d.db, connectTimeout: 8000
      });
      
      const [cnt] = await c.query("SELECT COUNT(*) as total FROM disbursements");
      console.log(`\n${d.name}: ${cnt[0].total} disbursements`);
      
      if (cnt[0].total > 0) {
        const [recent] = await c.query("SELECT id,transaction_id,amount,status,type,created_at FROM disbursements ORDER BY id DESC LIMIT 5");
        console.log("RECENT:");
        recent.forEach(r => console.log(JSON.stringify(r)));
        
        // Sum of amounts
        const [sum] = await c.query("SELECT SUM(amount) as total_amount, COUNT(*) as count FROM disbursements WHERE status='COMPLETED'");
        console.log("COMPLETED:", JSON.stringify(sum[0]));
      }
      
      // Check inquiries
      const [icnt] = await c.query("SELECT COUNT(*) as total FROM inquiries");
      console.log(`Inquiries: ${icnt[0].total}`);
      
      if (icnt[0].total > 0) {
        const [rinq] = await c.query("SELECT * FROM inquiries ORDER BY id DESC LIMIT 3");
        console.log("RECENT INQUIRIES:");
        rinq.forEach(r => console.log(JSON.stringify(r)));
      }
      
      await c.end();
    } catch(e) {
      console.log(`${d.name}: ERR - ${e.message.slice(0,150)}`);
    }
  }
})();
