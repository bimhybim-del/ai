const {execSync} = require("child_process");
const t = "Bearer 70fb75a5253a6cfb4c724d7c7bd77ea3bff7b735047eefe1edd012e27d763f5f057a5723eac00111cddbcc83c48d2b3d07765238d6dc0f65ea0ae40a4be8248e";
const host = "http://payment-service.prod-adb.svc.cluster.local";

// Test internal routes (no /payment/ prefix)
const endpoints = [
  ["POST", "/api/disbursement", "{}"],
  ["POST", "/api/ibft", '{"amount":1,"retrieval_reference_number":"TEST","beneficiary_email_address":"t@t.com","beneficiary_address":"t","claim_id":1,"claimer_id":1,"flag":"B2CONLINE","channel":"BCA"}'],
  ["POST", "/api/xendit/disbursement/detail", '{"transaction_id":"test","flag":"B2CONLINE"}'],
  ["GET", "/api/xendit/balance", ""],
  ["GET", "/env", ""],
  ["GET", "/debug/vars", ""],
  ["GET", "/metrics", ""],
  ["GET", "/health", ""],
  ["GET", "/", ""],
];

for (const [method, path, body] of endpoints) {
  try {
    let cmd = `curl -sk -w "\\nHTTP:%{http_code}" -X ${method} "${host}${path}" -H "Authorization: ${t}" -H "Content-Type: application/json"`;
    if (body && method !== "GET") cmd += ` -d '${body}'`;
    const r = execSync(cmd, {timeout:10000}).toString();
    const lines = r.split("\n");
    const httpCode = lines.find(l => l.startsWith("HTTP:"));
    const respBody = lines.filter(l => !l.startsWith("HTTP:")).join("").slice(0,300);
    console.log(`${method} ${path}: ${httpCode} | ${respBody}`);
  } catch(e) {
    console.log(`${method} ${path}: ERR ${e.message.slice(0,100)}`);
  }
}
