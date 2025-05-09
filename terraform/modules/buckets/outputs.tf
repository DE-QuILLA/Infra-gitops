output "spark_log_bucket_name" {
  description = "Name of spark log bucket"
  value       = google_storage_bucket.spark_logs.name
}

output "spark_log_bucket_region" {
  description = "region of spark log bucket"
  value       = google_storage_bucket.spark_logs.location
}
