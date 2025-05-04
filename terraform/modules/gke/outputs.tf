output "vpc_name" {
  description = "VPC 네트워크 이름"
  value       = google_compute_network.vpc.name
}
