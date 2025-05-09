# -------- 0. 공통 기본 설정 -------- #
variable "gcp_region" {
  type    = string
  default = "asia-northeast3" # 서울 리전
}

variable "gcp_project_id" {
  type    = string
  default = "de-quilla"
}

variable "gcp_zone" {
  type    = string
  default = "asia-northeast3-a"
}

# -------- 1. VPC 모듈용 variable -------- #
variable "gcp_vpc_name" {
  type    = string
  default = "deq-vpc"
}

variable "gcp_public_subnet_name" {
  type    = string
  default = "deq-vpc-public"
}

variable "gcp_public_subnet_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

# -------- 2. Cloud SQL 모듈용 variable -------- #
variable "airflow_meta_db_instance_name" {
  type    = string
  default = "airflow-sql"
}

variable "airflow_meta_db_version" {
  type    = string
  default = "POSTGRES_14"
}

variable "airflow_meta_db_tier" {
  type    = string
  default = "db-custom-2-8192" # 2 vCPU, 8GB RAM
}

variable "airflow_meta_db_user" {
  type    = string
  default = "airflow"
}

variable "airflow_meta_db_password" {
  type    = string
  default = "postgres"
}

variable "airflow_meta_db_db_name" {
  type    = string
  default = "airflowdb"
}

# -------- 3. GKE 모듈용 variable -------- #
variable "gke_cluster_name" {
  description = "GKE Cluster Name"
  type        = string
  default     = "data-gke"
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
  default     = 10
}

variable "gke_desired_size" {
  description = "GKE Node Pool Initial Size"
  type        = number
  default     = 1
}

# -------- 4. Kafka 클러스터 모듈용 variable -------- #
variable "kafka_node_count" {
  type    = number
  default = 5
}

variable "kafka_node_machine_type" {
  type    = string
  default = "e2-standard-4"
}

# -------- 5. Click house 클러스터 모듈용 variable -------- #

# -------- 6. ELK 클러스터 모듈용 variable -------- #

# -------- 7. BigQuery 클러스터 모듈용 variable -------- #

# -------- 8. GCS 모듈 용 variable -------- #
variable "spark_log_bucket_name" {
  description = "Name of spark log bucket"
  type        = string
  default     = "deq-spark-log-bucket"
}

variable "spark_log_bucket_location" {
  description = "Location(Region) of spark log bucket"
  type        = string
  default     = "asia-northeast3"
}
