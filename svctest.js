const {execSync} = require("child_process");
const dns = require("dns");

// Try common service names for payment
const names = [
  "payment-service.prod-adb.svc.cluster.local",
  "payment-service.prod-adb",
  "payment.prod-adb.svc.cluster.local",
  "payment.prod-adb",
  "payment-service",
  "payment-svc.prod-adb.svc.cluster.local",
  "volo-payment.prod-adb.svc.cluster.local",
];

for (const n of names) {
  try {
    const r = execSync(`getent hosts ${n} 2>&1 | head -1`, {timeout:3000}).toString().trim();
    if (r && !r.includes("not found")) {
      console.log(`DNS ${n}: ${r}`);
      // Try HTTP
      const h = execSync(`curl -sk -o /dev/null -w "%{http_code}" http://${n}/api/payment/xendit/balance 2>&1`, {timeout:5000}).toString().trim();
      console.log(`  HTTP: ${h}`);
    }
  } catch(e) {}
}

// Also check what env vars reveal about payment service
try {
  const r = execSync('env | grep -i payment | head -10', {timeout:3000}).toString();
  console.log("\nPAYMENT ENV:", r);
} catch(e) {}

// Check /etc/resolv.conf for search domains
try {
  const r = execSync('cat /etc/resolv.conf', {timeout:3000}).toString();
  console.log("\nRESOLV:", r);
} catch(e) {}
