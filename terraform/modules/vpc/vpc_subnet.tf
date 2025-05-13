# vpc: 간단한 vpc 새로 생성
resource "google_compute_network" "vpc" {
  name                    = var.gcp_vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# 서브넷 구조: 우선 퍼블릭한 서브넷 하나만 구성함.
resource "google_compute_subnetwork" "public_subnet" {
  name                     = var.gcp_public_subnet_name
  ip_cidr_range            = var.gcp_public_subnet_cidr
  region                   = var.gcp_region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}
