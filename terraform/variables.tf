variable "project" {
  description = "The GCP project to deploy resources to"
  type = string
}

variable "region" {
    description = "The GCP region to deploy resources to"
    type = string
}

variable "data_bucket_name" {
    description = "The name of the GCS bucket where data will be stored"
    type = string
}

variable "artifact_registry_name" {
    description = "The name of the Artifact Registry to deploy resources to"
    type = string
}

variable "kraken_trade_extract_agent_image" {
    description = "The name of the Docker image to build and deploy"
    type = string
}

variable "kraken_trade_extract_agent_cloud_run_job_name" {
    description = "The name of the Cloud Run job to deploy"
    type = string
}

variable "bigquery_raw_dataset_name" {
    description = "The name of the BigQuery dataset to deploy resources to"
    type = string
}