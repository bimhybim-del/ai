const {execSync} = require("child_process");
const flags = ["B2CONLINE","B2COFFLINE","B2B2C","B2B2C_ADB","OPENVA","B2COFFLINE_MJP","SMP","PARTNERSHIP"];
const types = ["CASH","HOLDING"];

for (const flag of flags) {
  for (const at of types) {
    try {
      const r = execSync(`curl -sk -G -m 10 "https://api.qoala.app/api/payment/xendit/balance" -d "account_type=${at}" -d "flag=${flag}" 2>&1`, {timeout:15000}).toString();
      console.log(`${flag} ${at}: ${r.slice(0,200)}`);
    } catch(e) {
      console.log(`${flag} ${at}: TIMEOUT/ERR`);
    }
  }
}
