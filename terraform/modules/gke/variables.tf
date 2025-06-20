variable "gcp_region" {
  description = "GCP Region"
  type        = string
}

variable "vpc_name" {
  description = "GCP VPC Name"
  type        = string
}

variable "subnet_name" {
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
  default     = "e2-standard-4"
}

variable "gke_min_size" {
  description = "GKE Node Pool Min Size"
  type        = number
  default     = 1
}

variable "gke_max_size" {
  description = "GKE Node Pool Max Size"
  type        = number
  default     = 7
}

variable "gke_desired_size" {
  description = "GKE Node Pool Initial Size"
  type        = number
  default     = 2
}
