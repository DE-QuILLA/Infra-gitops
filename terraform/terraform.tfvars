# GCP 관련 기본 설정
gcp_project_id         = "de-quilla"       # pragma: allowlist secret
gcp_region             = "asia-northeast3" # pragma: allowlist secret
gcp_zone               = "asia-northeast3-a"
gcp_vpc_name           = "deq-vpc"
gcp_public_subnet_name = "deq-vpc-public"
gcp_public_subnet_cidr = "10.10.0.0/16"

# GKE 관련 기본 설정
gke_cluster_name = "dequila-gke-cluster" # pragma: allowlist secret
gke_machine_type = "e2-standard-4"
gke_min_size     = 1
gke_max_size     = 10
gke_desired_size = 2

# Cloud SQL 관련 기본 설정
airflow_meta_db_instance_name = "airflow-sql"
airflow_meta_db_version       = "POSTGRES_14"
airflow_meta_db_tier          = "db-custom-2-8192"
airflow_meta_db_user          = "airflow"
airflow_meta_db_password      = "postgres" # pragma: allowlist secret
airflow_meta_db_db_name       = "airflowdb"

# Kafka 관련 기본 설정
kafka_node_count        = 5
kafka_node_machine_type = "e2-standard-4"

# GCS 관련 기본 설정
spark_log_bucket_name     = "deq-spark-log-bucket"
spark_log_bucket_location = "asia-northeast3"
