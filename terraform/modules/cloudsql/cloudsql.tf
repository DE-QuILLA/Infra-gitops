# CloudSQL 인스턴스
resource "google_sql_database_instance" "airflow_meta_db_instance" {
  name                = var.airflow_meta_db_instance_name
  database_version    = var.airflow_meta_db_version
  region              = var.gcp_region
  deletion_protection = false

  settings {
    tier = var.airflow_meta_db_tier

    ip_configuration {
      ipv4_enabled = true
    }
  }
}

# airflow용 유저와 db 생성
resource "google_sql_user" "airflow_meta_db_user" {
  name     = var.airflow_meta_db_user
  instance = google_sql_database_instance.airflow_meta_db_instance.name
  password = var.airflow_meta_db_password
}

resource "google_sql_database" "airflow_meta_db_db" {
  name     = var.airflow_meta_db_db_name
  instance = google_sql_database_instance.airflow_meta_db_instance.name
}
