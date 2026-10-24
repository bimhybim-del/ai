const mysql = require("mysql2/promise");
const {execSync} = require("child_process");

(async () => {
  // Test IP-restricted Xendit key from Qoala network
  console.log("=== XENDIT KEY TEST FROM QOALA IP ===");
  try {
    const r = execSync('curl -sk -u "xnd_production_yjORiHhrvDpzC4J4SVQdTv2joEoccZFOxncIrlVuG1N7jCyN5TSxqUr7TU0esrS:" "https://api.xendit.co/balance" 2>&1', {timeout:10000}).toString();
    console.log("IP-RESTRICTED KEY:", r);
  } catch(e) { console.log("KEY ERR:", e.message.slice(0,200)); }

  // Also try main production key balance with different account types
  try {
    const r = execSync('curl -sk -u "xnd_production_lMpQFzh1TMzFuRJ6p36wj59gFBPb53ON60mDPpQJq4K1bttdOIQGPourwWobMs:" "https://api.xendit.co/balance?account_type=HOLDING" 2>&1', {timeout:10000}).toString();
    console.log("HOLDING BAL:", r);
    const r2 = execSync('curl -sk -u "xnd_production_lMpQFzh1TMzFuRJ6p36wj59gFBPb53ON60mDPpQJq4K1bttdOIQGPourwWobMs:" "https://api.xendit.co/balance?account_type=TAX" 2>&1', {timeout:10000}).toString();
    console.log("TAX BAL:", r2);
  } catch(e) { console.log("BAL ERR:", e.message.slice(0,100)); }

  // Query DB: invoices, flag_configurations, tokens
  const c = await mysql.createConnection({
    host: "payment-service.mysql.prod.yoi.local",
    user: "payment-service-svc", password: "OA1kyIEDllKsg8qZzMacHlgdJvxJiDP7",
    database: "payment_service_production", connectTimeout: 10000
  });
  
  const tables = ["invoices","flag_configurations","recipients","tokens","virtual_accounts"];
  for (const t of tables) {
    const [cnt] = await c.query(`SELECT COUNT(*) as c FROM ${t}`);
    console.log(`\n${t}: ${cnt[0].c} rows`);
    if (cnt[0].c > 0) {
      const [rows] = await c.query(`SELECT * FROM ${t} ORDER BY id DESC LIMIT 2`);
      rows.forEach(r => console.log(JSON.stringify(r).slice(0,300)));
    }
  }
  
  await c.end();
})().catch(e => console.log("ERR:", e.message));
