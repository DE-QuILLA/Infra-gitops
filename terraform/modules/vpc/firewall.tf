# vpc내 공용 inbound 규칙
# 디버깅 편의를 위하여 모든 포트에서의 접근을 허용 - 추후 private subnet 추가, 일부 포트만 열도록 고도화
resource "google_compute_firewall" "allow_all_inbound" {
  name    = "allow-all-inbound"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gke-node", "kafka-node", "elk-node", "ch-node"]
}

# 추후 inbound 네트워크 조정이 각자 필요한 경우 아래와 같이 별도 리소스를 생성할 수 있음.
# 노드 그룹별로 분리 등은 테라폼에서 불능, vpc + tag 기반으로 구분.
# 아래 예시는 kafka-node의 제한된 포트에 대한 inbound만 허용하는 방화벽 생성 => 위에서 tags에서 제외하고 여기에 추가하면 됨.
# resource "google_compute_firewall" "kafka_inbound_rule" {
#   name    = "kafka-inbound-rule"
#   network = google_compute_network.vpc.name

#   allow {
#     protocol = "tcp"
#     ports    = ["80", "443", "8080", "22", "880"]
#   }

#   direction     = "INGRESS"
#   source_ranges = ["0.0.0.0/0"]
#   target_tags = ["kafka-node"]
# }
