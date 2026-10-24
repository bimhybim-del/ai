const {execSync} = require("child_process");
const payload = JSON.stringify({
  id: "test-disb-001",
  user_id: "test-user", 
  external_id: "ASSESS-001",
  amount: 100,
  bank_code: "BCA",
  account_holder_name: "Assessment Test",
  disbursement_description: "validation",
  failure_code: "",
  is_instant: true,
  status: "COMPLETED",
  created: "2026-10-24T00:00:00.000Z",
  updated: "2026-10-24T00:00:00.000Z"
});

// Test callback endpoint
try {
  const r = execSync(`curl -sk -X POST "https://api.qoala.app/api/payment/xendit/disbursement/callback" -H "Content-Type: application/json" -d '${payload}' 2>&1`, {timeout:15000}).toString();
  console.log("CALLBACK:", r.slice(0,500));
} catch(e) {
  console.log("CALLBACK ERR:", e.message.slice(0,300));
}

// Also test X-CALLBACK-TOKEN header (APIKeyPartner middleware used for some callbacks)
try {
  // X-CALLBACK-TOKEN from K8s secrets
  const r2 = execSync(`curl -sk -X POST "https://api.qoala.app/api/payment/xendit/disbursement/callback" -H "Content-Type: application/json" -H "X-CALLBACK-TOKEN: test" -d '${payload}' 2>&1`, {timeout:15000}).toString();
  console.log("CALLBACK+TOKEN:", r2.slice(0,500));
} catch(e) {
  console.log("CALLBACK+TOKEN ERR:", e.message.slice(0,200));
}
