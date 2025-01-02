resource "google_bigquery_dataset" "bigquery_raw_dataset" {
  dataset_id = var.bigquery_raw_dataset_name
  project    = var.project
  location   = var.region
  
}