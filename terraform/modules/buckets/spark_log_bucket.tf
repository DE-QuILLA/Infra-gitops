resource "google_storage_bucket" "spark_logs" {
  name          = var.spark_log_bucket_name
  location      = var.spark_log_bucket_location
  force_destroy = true

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}
