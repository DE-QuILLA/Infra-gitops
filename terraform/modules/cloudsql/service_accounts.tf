# ---------------------- Service Account & Key ----------------------
resource "google_service_account" "cloudsql_sa" {
  account_id   = "cloudsql-proxy-airflow"
  display_name = "CloudSQL Proxy SA"
}

resource "google_project_iam_member" "cloudsql_sa_binding" {
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudsql_sa.email}"
  project = var.project_id
}

resource "google_service_account_key" "cloudsql_sa_key" {
  service_account_id = google_service_account.cloudsql_sa.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE" # pragma: allowlist secret
}

resource "local_file" "cloudsql_key_file" {
  content  = base64decode(google_service_account_key.cloudsql_sa_key.private_key)
  filename = "../../../deploy/key.json"
}
