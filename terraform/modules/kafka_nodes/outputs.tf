output "kafka_node_public_ips" {
  description = "Kafka nodes external (public) IPs"
  value       = google_compute_instance.kafka_nodes[*].network_interface[0].access_config[0].nat_ip
}

output "kafka_node_private_ips" {
  description = "Kafka nodes internal (private) IPs"
  value       = google_compute_instance.kafka_nodes[*].network_interface[0].network_ip
}
