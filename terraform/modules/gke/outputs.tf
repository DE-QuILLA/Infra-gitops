output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.deq_gke_cluster.name
}

output "gke_node_pool_name" {
  description = "GKE cluster primary node pool's name"
  value       = google_compute_network.vpc.name
}
