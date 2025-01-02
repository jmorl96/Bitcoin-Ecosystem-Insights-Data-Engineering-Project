resource "google_artifact_registry_repository" "docker_repository" {
  location      = var.region
  repository_id = var.artifact_registry_name
  description   = "Docker repository"
  format        = "DOCKER"

  provisioner "local-exec" {
    command = "gcloud builds submit --config=../cloudbuild.yaml   --substitutions=_REPOSITORY='${var.artifact_registry_name}',_IMAGE_NAME='${var.kraken_trade_extract_agent_image}',_LOCATION='${var.region}' ../."
    when = create
  }
}