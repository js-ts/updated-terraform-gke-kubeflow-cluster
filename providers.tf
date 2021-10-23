# set project for the provider as a whole to avoid having to repeat it for each resource
provider "google" {
  project = var.project
  version = "~> 3.89.0"
}

provider "google-beta" {
  project = var.project
  version = "~> 3.89.0"
}

provider "random" {
  version = "~> 3.1.0"
}

provider "null" {
  version = "~> 3.1.0"
}

provider "kubernetes" {
  version = ">= 2.6.0"

  # instead use the cluster managed by this module
  host                   = format("https://%s", local.cluster_endpoint)
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(local.cluster_ca_certificate)
}

locals {
  cluster_endpoint       = google_container_cluster.kubeflow_cluster.endpoint
  cluster_ca_certificate = google_container_cluster.kubeflow_cluster.master_auth.0.cluster_ca_certificate
}
