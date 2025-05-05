# main.tf를 실행할 때 외부에서 참고하고 싶다면 모듈 뿐 아니라 terraform 프로젝트 루트 경로의 outputs.tf 작성 필요

output "kafka_node_public_ips" {
  description = "Kafka nodes external (public) IPs"
  value       = google_compute_instance.kafka_nodes[*].network_interface[0].access_config[0].nat_ip
}

output "kafka_node_private_ips" {
  description = "Kafka nodes internal (private) IPs"
  value       = google_compute_instance.kafka_nodes[*].network_interface[0].network_ip
}
