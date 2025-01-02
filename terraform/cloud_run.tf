resource "google_cloud_run_v2_job" "kraken_data_extract" {
  depends_on = [ google_artifact_registry_repository.docker_repository ]
  name     = var.kraken_trade_extract_agent_cloud_run_job_name
  location = var.region
  deletion_protection = false

  template {
    template {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project}/${var.artifact_registry_name}/${var.kraken_trade_extract_agent_image}:latest"
      }
    }
  }
}