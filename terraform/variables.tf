// Define the variables that will be used in the Terraform configuration

// Basic variables for the project, must be set by the user

variable "project" {
  description = "The GCP project to deploy resources to"
  type = string
}

variable "region" {
    description = "The GCP region to deploy resources to"
    type = string
}

// Variables for the GCS buckets

variable "data_bucket_name" {
    description = "The name of the GCS bucket where data will be stored"
    type = string
}

variable "composer_bucket_name" {
    description = "The name of the GCS bucket for Composer"
    type = string
}

// Variables for the Artifact Registry

variable "artifact_registry_name" {
    description = "The name of the Artifact Registry to deploy resources to"
    type = string
}

// Image variables for the Cloud Run jobs and Cloud Run jobs names

variable "kraken_trade_data_extraction_image" {
    description = "The name of the Docker image to build and deploy"
    type = string
}

variable "dbt_image" {
    description = "The name of the Docker image to build and deploy"
    type = string
}

variable "kraken_trade_data_extraction_cloud_run_job_name" {
    description = "The name of the Cloud Run job to deploy"
    type = string
}

variable "dbt_cloud_run_job_name" {
    description = "The name of the Cloud Run job to deploy"
    type = string
}

// Variables for the BigQuery datasets and location

variable "bigquery_bronze_dataset_name" {
    description = "The name of the BigQuery dataset to deploy raw tables to"
    type = string
}

variable "bigquery_silver_dataset_name" {
    description = "The name of the BigQuery dataset to deploy stagging resources to"
    type = string
}

variable "bigquery_gold_dataset_name" {
    description = "The name of the BigQuery dataset to deploy the final tables to"
    type = string
}

variable "bigquery_platinum_dataset_name" {
    description = "The name of the BigQuery dataset to deploy exposition tables to"
    type = string
}

variable "bigquery_location" {
    description = "The location for the BigQuery datasets"
    type = string
}