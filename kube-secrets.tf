resource "kubernetes_namespace" "kubeflow" {
  depends_on = [
    google_container_node_pool.gpu_pool,
    google_container_node_pool.highmem_pool,
    google_container_node_pool.main_pool,
  ]

  metadata {
    name = "kubeflow"
  }

  timeouts {
    delete = var.timeout
  }
}

resource "kubernetes_namespace" "istio-system" {
  depends_on = [
    google_container_node_pool.gpu_pool,
    google_container_node_pool.highmem_pool,
    google_container_node_pool.main_pool,
  ]
  count = var.istio_enabled ? 1 : 0

  metadata {
    name = "istio-system"
    labels = {
      "istio-injection" = "disabled"
    }
  }

  timeouts {
    delete = var.timeout
  }
}

# Create a Kubernetes secret for the cloudsql-proxy's credentials
resource "kubernetes_secret" "cloudsql-instance-credentials" {
  depends_on = [kubernetes_namespace.kubeflow]

  metadata {
    namespace = "kubeflow"
    name      = "cloudsql-instance-credentials"
  }

  data = {
    "credentials.json" = base64decode(google_service_account_key.cloudsql_proxy_key.private_key)
  }
}

# Kubeflow instructions mention creating a "user-gcp-sa" containing credentials
# for the GCP SA for the "-user" account, which some of the sample pipelines
# expect to use/mount in order to talk to GCP resources in their pipeline
# steps.
resource "kubernetes_secret" "user-gcp-sa" {
  depends_on = [kubernetes_namespace.kubeflow]

  metadata {
    namespace = "kubeflow"
    name      = "user-gcp-sa"
  }

  data = {
    "user-gcp-sa.json" = base64decode(google_service_account_key.kubeflow_user_key.private_key)
  }
}

# Create the admin-gcp-sa secret too
resource "kubernetes_secret" "admin-gcp-sa" {
  depends_on = [kubernetes_namespace.kubeflow]

  metadata {
    namespace = "kubeflow"
    name      = "admin-gcp-sa"
  }

  data = {
    "admin-gcp-sa.json" = base64decode(google_service_account_key.kubeflow_admin_key.private_key)
  }
}

resource "kubernetes_secret" "istio_admin-gcp-sa" {
  count = var.istio_enabled ? 1 : 0

  depends_on = [kubernetes_namespace.istio-system]

  metadata {
    namespace = "istio-system"
    name      = "admin-gcp-sa"
  }

  data = {
    "admin-gcp-sa.json" = base64decode(google_service_account_key.kubeflow_admin_key.private_key)
  }
}
