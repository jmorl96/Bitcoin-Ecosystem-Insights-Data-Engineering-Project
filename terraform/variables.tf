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