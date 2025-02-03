// Composer Service Account

resource "google_service_account" "composer_service_account" {
  account_id   = "composer-service-account"
  display_name = "Composer Custom Service Account"
}

resource "google_project_iam_member" "composer_service_account_worker_role" {
  project  = var.project
  member   = format("serviceAccount:%s", google_service_account.composer_service_account.email)
  // Role for Public IP environments
  role     = "roles/composer.worker"
}

resource "google_project_iam_member" "composer_service_account_cloud_run_jobs_executor_role" {
  project  = var.project
  member   = format("serviceAccount:%s", google_service_account.composer_service_account.email)
  role     = "roles/run.jobsExecutorWithOverrides"
}

resource "google_project_iam_member" "composer_service_account_cloud_run_viewer_role" {
  project  = var.project
  member   = format("serviceAccount:%s", google_service_account.composer_service_account.email)
  role     = "roles/run.viewer"
}

// Cloud Run Service Account

resource "google_service_account" "cloud_run_service_account" {
  account_id   = "cloud-run-service-account"
  display_name = "Cloud Run Custom Service Account"
}

resource "google_project_iam_member" "cloud_run_service_account_bigquery_user_role" {
  project  = var.project
  member   = format("serviceAccount:%s", google_service_account.cloud_run_service_account.email)
  role     = "roles/bigquery.user"
}

resource "google_project_iam_member" "cloud_run_service_account_bigquery_data_editor_role" {
  project  = var.project
  member   = format("serviceAccount:%s", google_service_account.cloud_run_service_account.email)
  role     = "roles/bigquery.dataEditor"
}

resource "google_project_iam_member" "cloud_run_service_account_storage_object_user_role" {
  project  = var.project
  member   = format("serviceAccount:%s", google_service_account.cloud_run_service_account.email)
  role     = "roles/storage.objectUser"
}

