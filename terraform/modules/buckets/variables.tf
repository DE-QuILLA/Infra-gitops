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
