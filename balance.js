const {execSync} = require("child_process");
const host = "http://payment-service.prod-adb.svc.cluster.local";

// Test all flags with is_scheduler to dump all balances
const flags = ["B2CONLINE","B2COFFLINE","B2B2C","B2B2C_ADB","OPENVA","B2COFFLINE_MJP"];
for (const flag of flags) {
  try {
    const r = execSync(`curl -sk "${host}/api/xendit/balance?account_type=CASH&flag=${flag}&is_scheduler=true&is_balance_update=true" 2>&1`, {timeout:15000}).toString();
    console.log(`${flag}: ${r.slice(0,500)}`);
  } catch(e) {
    console.log(`${flag} ERR: ${e.message.slice(0,100)}`);
  }
}

// Also try individual balance query
console.log("\n=== INDIVIDUAL BALANCE ===");
const types = ["CASH","HOLDING","TAX"];
for (const at of types) {
  try {
    const r = execSync(`curl -sk "${host}/api/xendit/balance?account_type=${at}&flag=B2CONLINE" 2>&1`, {timeout:10000}).toString();
    console.log(`B2CONLINE ${at}: ${r.slice(0,300)}`);
  } catch(e) {}
}
