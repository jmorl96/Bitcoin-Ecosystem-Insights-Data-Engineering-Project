// BigQuery Datasets

resource "google_bigquery_dataset" "bigquery_bronze_dataset" {
  dataset_id = var.bigquery_bronze_dataset_name
  project    = var.project
  location   = var.bigquery_location
  delete_contents_on_destroy = true
  
}
resource "google_bigquery_dataset" "bigquery_silver_dataset" {
  dataset_id = var.bigquery_silver_dataset_name
  project    = var.project
  location   = var.bigquery_location
  delete_contents_on_destroy = true
  
}

resource "google_bigquery_dataset" "bigquery_gold_dataset" {
  dataset_id = var.bigquery_gold_dataset_name
  project    = var.project
  location   = var.bigquery_location
  delete_contents_on_destroy = true
  
}

resource "google_bigquery_dataset" "bigquery_platinum_dataset" {
  dataset_id = var.bigquery_platinum_dataset_name
  project    = var.project
  location   = var.bigquery_location
  delete_contents_on_destroy = true
  
}