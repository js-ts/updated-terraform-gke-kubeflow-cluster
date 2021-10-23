# Setup for Velero for backing up cluster state
# https://velero.io/docs/v1.0.0/gcp-config/
#
# Creates:
# - one GCS bucket
# - one GCP Service Account
# - necessary IAM bindings for the SA to write/read to the bucket
# - k8s namespace for Velero
# - k8s secret for Velero to use the GCP SA
# These resources are per module instance, so we get one per cluster.

locals {
  namespace = "velero"
}

# Create a unique GCS bucket per cluster
resource "google_storage_bucket" "backup_bucket" {
  name = format("%s_%s_%s_backup", var.project, var.cluster_region, var.cluster_name)

  uniform_bucket_level_access = true

  location = "EU"
}

resource "google_service_account" "velero" {
  project      = var.project
  account_id   = format("%s-velero", var.cluster_name)
  display_name = format("Velero account for %s", var.cluster_name)
}

resource "google_service_account_key" "velero" {
  service_account_id = google_service_account.velero.name
}

resource "google_storage_bucket_iam_binding" "ark_bucket_iam" {
  bucket = google_storage_bucket.backup_bucket.name
  role   = "roles/storage.objectAdmin"

  members = [
    format("serviceAccount:%s", google_service_account.velero.email)
  ]
}

resource "kubernetes_namespace" "velero" {
  depends_on = [
    google_container_node_pool.gpu_pool,
    google_container_node_pool.highmem_pool,
    google_container_node_pool.main_pool,
  ]
  metadata {
    name = local.namespace
    labels = {
      "component" = "velero"
    }
  }

  timeouts {
    delete = var.timeout
  }
}

resource "kubernetes_secret" "service_account_key" {
  depends_on = [kubernetes_namespace.velero]

  metadata {
    namespace = local.namespace
    name      = "cloud-credentials"
    labels = {
      "component" = "velero"
    }
  }

  data = {
    "cloud" = base64decode(google_service_account_key.velero.private_key)
  }
}
