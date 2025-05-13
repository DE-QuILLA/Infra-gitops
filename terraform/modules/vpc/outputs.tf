output "vpc_name" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
}

output "public_subnet_name" {
  description = "Public 서브넷 이름"
  value       = google_compute_subnetwork.public_subnet.name
}

output "firewall_rule_names" {
  description = "방화벽 이름"
  value = [
    google_compute_firewall.allow_all_inbound.name,
    # output으로 다른 모듈에서 받아 사용하고 싶다면 아래와 같이 리소스 id 기반 추가 가능함
    # google_compute_firewall.kafka_inbound_firewall.name
  ]

}
