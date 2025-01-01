resource "google_storage_bucket" "data_bucket" {
    name = var.data_bucket_name
    location = var.region
}