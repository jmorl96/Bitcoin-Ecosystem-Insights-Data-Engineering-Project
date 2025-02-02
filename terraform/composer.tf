// Composer Environment

resource "google_composer_environment" "composer_enviroment" {
  name = "composer-environment"
  region = var.region

  config {

    software_config {
      image_version = "composer-3-airflow-2.10.2-build.7"

      env_variables = {
        custom_project_id = var.project
        custom_region = var.region
        custom_data_bucket = var.data_bucket_name
        custom_extract_job_name = var.kraken_trade_data_extraction_cloud_run_job_name
        custom_dbt_job_name = var.dbt_cloud_run_job_name
      }
    }

    node_config {
      service_account = google_service_account.composer_service_account.email
    }

    environment_size = "ENVIRONMENT_SIZE_SMALL"

  }

  storage_config {
    bucket = google_storage_bucket.composer_bucket.name
  }
}
