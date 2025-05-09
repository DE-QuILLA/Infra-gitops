# ---------------------------- Providers ---------------------------- #
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "google" {
  project = var.project_id
  region  = var.gcp_region
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.current.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

# ---------------------------- VPC ---------------------------- #
module "vpc" {
  source             = "./modules/vpc"
  gcp_vpc_name       = var.gcp_vpc_name
  subnet_public_cidr = var.subnet_public_cidr
  gcp_region         = var.gcp_region
}

# ------------------------- CloudSQL and SAs ------------------------- #
module "cloudsql" {
  source         = "./modules/cloudsql"
  project_id     = var.gcp_project_id
  region         = var.gcp_region
  db_instance_id = var.db_instance_id
  db_name        = var.db_name
  db_user        = var.db_user
  db_password    = var.db_password
}

# ---------------------------- GKE ----------------------------
module "gke" {
  source           = "./modules/gke"
  gke_cluster_name = var.gke_cluster_name
  gcp_region       = var.gcp_region
  network_name     = module.vpc.network_name
  subnet_name      = module.vpc.subnet_name
  gke_machine_type = var.gke_machine_type
  desired_size     = var.gke_desired_size
  min_size         = var.gke_min_size
  max_size         = var.gke_max_size
}

# kubeconfig
resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.gke_cluster_name} --region ${var.gcp_region} --project ${var.project_id}"
  }
  depends_on = [module.gke]
}

# ---------------------------- GCE modules ---------------------------- #
module "elk_nodes" {
  source     = "./modules/elk_nodes"
  project_id = var.project_id
  region     = var.gcp_region
  network    = module.vpc.vpc_name
  subnet     = module.vpc.subnet_name
}

module "kafka_nodes" {
  source     = "./modules/kafka_nodes"
  project_id = var.project_id
  region     = var.gcp_region
  network    = module.vpc.vpc_name
  subnet     = module.vpc.subnet_name
}

module "ch_nodes" {
  source     = "./modules/ch_nodes"
  project_id = var.project_id
  region     = var.gcp_region
  network    = module.vpc.vpc_name
  subnet     = module.vpc.subnet_name
}

# ---------------------------- BigQuery ----------------------------
module "bigquery" {
  source     = "./modules/bigquery"
  project_id = var.project_id
  dataset_id = var.bq_dataset_id
}

# ---------------------------- END ----------------------------
