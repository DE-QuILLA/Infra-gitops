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
  project = var.gcp_project_id
  region  = var.gcp_region
}

# ---------------------------- VPC ---------------------------- #
module "vpc" {
  source                 = "./modules/vpc"
  gcp_vpc_name           = var.gcp_vpc_name
  gcp_public_subnet_cidr = var.gcp_public_subnet_cidr
  gcp_public_subnet_name = var.gcp_public_subnet_name
  gcp_region             = var.gcp_region # GCP 설계 상 서브넷에만 region 적용된다고 함.
}

# ------------------------- CloudSQL and SAs ------------------------- #
module "cloudsql" {
  source                        = "./modules/cloudsql"
  gcp_project_id                = var.gcp_project_id
  gcp_region                    = var.gcp_region
  airflow_meta_db_instance_name = var.airflow_meta_db_instance_name
  airflow_meta_db_version       = var.airflow_meta_db_version
  airflow_meta_db_tier          = var.airflow_meta_db_tier
  airflow_meta_db_user          = var.airflow_meta_db_user
  airflow_meta_db_password      = var.airflow_meta_db_password
  airflow_meta_db_db_name       = var.airflow_meta_db_db_name
}

# ---------------------------- GKE ---------------------------- #
module "gke" {
  source                 = "./modules/gke"
  gcp_region             = var.gcp_region
  gcp_vpc_name           = var.gcp_vpc_name
  gcp_public_subnet_name = var.gcp_public_subnet_name
  gke_cluster_name       = var.gke_cluster_name
  gke_machine_type       = var.gke_machine_type
  gke_desired_size       = var.gke_desired_size
  gke_min_size           = var.gke_min_size
  gke_max_size           = var.gke_max_size
}

# kubeconfig
resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.gke_cluster_name} --region ${var.gcp_region} --project ${var.gcp_project_id}"
  }
  depends_on = [module.gke]
}

# ---------------------------- GCE modules ---------------------------- #
# 아래는 모두 GKE 내의 서비스로 통합 예정
# module "elk_nodes" {
#   source     = "./modules/elk_nodes"
#   project_id = var.project_id
#   region     = var.gcp_region
#   network    = module.vpc.vpc_name
#   subnet     = module.vpc.subnet_name
# }

# module "kafka_nodes" {
#   source                  = "./modules/kafka_nodes"
#   kafka_node_count        = var.kafka_node_count
#   kafka_node_machine_type = var.kafka_node_machine_type
#   gcp_project_id          = var.gcp_project_id
#   gcp_vpc_name            = var.gcp_vpc_name
#   gcp_public_subnet_name  = var.gcp_public_subnet_name
#   gcp_zone                = var.gcp_zone
# }


# module "ch_nodes" {
#   source     = "./modules/ch_nodes"
#   project_id = var.project_id
#   region     = var.gcp_region
#   network    = module.vpc.vpc_name
#   subnet     = module.vpc.subnet_name
# }

# ---------------------------- BigQuery ----------------------------
# module "bigquery" {
#   source     = "./modules/bigquery"
#   project_id = var.project_id
#   dataset_id = var.bq_dataset_id
# }

# ---------------------------- GCS ----------------------------

module "buckets" {
  source                    = "./modules/buckets"
  spark_log_bucket_name     = var.spark_log_bucket_name
  spark_log_bucket_location = var.spark_log_bucket_location
}

# ---------------------------- END ----------------------------
