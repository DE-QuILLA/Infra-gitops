output "cloudsql_instance_name" {
  description = "CloudSQL airflow meta DB instance name"
  value       = google_sql_database_instance.airflow_meta_db_instance.name
}

output "cloudsql_instance_connection_name" {
  description = "CloudSQL airflow meta DB connection name"
  value       = google_sql_database_instance.airflow_meta_db_instance.connection_name
}

output "cloudsql_airflow_user_name" {
  description = "CloudSQL airflow meta DB user name for airflow"
  value       = google_sql_user.airflow_meta_db_user.name
}

output "cloudsql_airflow_db_name" {
  description = "CloudSQL airflow meta DB database name"
  value       = google_sql_database.airflow_meta_db_db.name
}

output "cloudsql_proxy_key_file_path" {
  description = "CloudSQL Proxy authetication key json file path"
  value       = local_file.cloudsql_key_file.filename
}
