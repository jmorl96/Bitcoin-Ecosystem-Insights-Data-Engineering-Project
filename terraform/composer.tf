// Composer Environment

resource "google_composer_environment" "composer_enviroment" {
  name = "composer-environment"
  region = var.region
  depends_on = [ google_artifact_registry_repository.docker_repository , google_cloud_run_v2_job.kraken_data_extract, google_cloud_run_v2_job.dbt ]

  config {

    software_config {
      image_version = "composer-3-airflow-2.10.2-build.7"

      env_variables = {
        AIRFLOW_VAR_CUSTOM_PROJECT_ID = var.project
        AIRFLOW_VAR_CUSTOM_REGION = var.region
        AIRFLOW_VAR_CUSTOM_DATA_BUCKET = var.data_bucket_name
        AIRFLOW_VAR_CUSTOM_EXTRACT_JOB_NAME = var.kraken_trade_data_extraction_cloud_run_job_name
        AIRFLOW_VAR_CUSTOM_DBT_JOB_NAME = var.dbt_cloud_run_job_name
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
