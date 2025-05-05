variable "gcp_region" {
  description = "GCP Region"
  type        = string
}

variable "gcp_vpc_name" {
  description = "GCP VPC Name"
  type        = string
}

variable "gcp_public_subnet_name" {
  description = "GCP Subnet Name"
  type        = string
}

variable "gke_cluster_name" {
  description = "GKE Cluster Name"
  type        = string
}

variable "gke_machine_type" {
  description = "GKE Node Machine Type"
  type        = string
}

variable "gke_min_size" {
  description = "GKE Node Pool Min Size"
  type        = number
}

variable "gke_max_size" {
  description = "GKE Node Pool Max Size"
  type        = number
}

variable "gke_desired_size" {
  description = "GKE Node Pool Initial Size"
  type        = number
}
