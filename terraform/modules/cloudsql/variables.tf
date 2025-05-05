variable "gcp_project_id" {
  type    = string
  default = "dequila"
}

variable "gcp_region" {
  type    = string
  default = "asia-northeast3"
}

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
  default = "airflow" # 2 vCPU, 8GB RAM
}

variable "airflow_meta_db_password" {
  type    = string
  default = "postgres"
}

variable "airflow_meta_db_db_name" {
  type    = string
  default = "airflowdb"
}
