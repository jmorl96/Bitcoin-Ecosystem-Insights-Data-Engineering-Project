// Cloud Storage Buckets

resource "google_storage_bucket" "data_bucket" {
    name = var.data_bucket_name
    location = var.region

    force_destroy = true
}

resource "google_storage_bucket" "composer_bucket" {
    name = var.composer_bucket_name
    location = var.region

    force_destroy = true
}

resource "google_storage_bucket_object" "airflow_dag" {
    name   = "dags/btc_de_project_dag.py"
    source = "../airflow/btc_de_project_dag.py"
    bucket = google_storage_bucket.composer_bucket.name
}