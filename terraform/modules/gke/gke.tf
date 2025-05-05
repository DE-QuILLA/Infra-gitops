# gke 클러스터 구성
resource "google_container_cluster" "deq_gke_cluster" {
  name     = var.gke_cluster_name
  location = var.gcp_region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.gcp_vpc_name
  subnetwork = var.gcp_public_subnet_name

  deletion_protection = false
  ip_allocation_policy {}
}

# 노드 풀 구성
resource "google_container_node_pool" "deq_gke_node_pool" {
  name       = "gke-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.deq_gke_cluster.name
  node_count = var.gke_desired_size

  node_config {
    machine_type = var.gke_machine_type
    disk_size_gb = 30
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"] # gke 내부의 pod가 프로젝트 내의 모든 활성화된 서비스에 접근 가능하도록 설정해둠.
    tags         = ["gke-node"]
  }

  autoscaling {
    min_node_count = var.gke_min_size
    max_node_count = var.gke_max_size
  }
}
