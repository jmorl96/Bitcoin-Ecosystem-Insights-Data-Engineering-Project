// Cloud Run Jobs

resource "google_cloud_run_v2_job" "kraken_data_extract" {
  depends_on = [ google_artifact_registry_repository.docker_repository ]
  name     = var.kraken_trade_data_extraction_cloud_run_job_name
  location = var.region
  deletion_protection = false

  template {
    template {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project}/${var.artifact_registry_name}/${var.kraken_trade_data_extraction_image}:latest"
      }
      service_account = google_service_account.cloud_run_service_account.email
    }
  }
}

resource "google_cloud_run_v2_job" "dbt" {
  depends_on = [ google_artifact_registry_repository.docker_repository ]
  name     = var.dbt_cloud_run_job_name
  location = var.region
  deletion_protection = false

  template {
    template {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project}/${var.artifact_registry_name}/${var.dbt_image}:latest"
      }
      service_account = google_service_account.cloud_run_service_account.email
    }
  }
}