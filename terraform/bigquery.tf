resource "google_bigquery_dataset" "bigquery_raw_dataset" {
  dataset_id = var.bigquery_bronze_dataset_name
  project    = var.project
  location   = var.bigquery_location
  delete_contents_on_destroy = true
  
}
resource "google_bigquery_dataset" "bigquery_stg_dataset" {
  dataset_id = var.bigquery_silver_dataset_name
  project    = var.project
  location   = var.bigquery_location
  delete_contents_on_destroy = true
  
}