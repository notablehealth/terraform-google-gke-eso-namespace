/**
 * # terraform-google-gke-eso-namespace
 *
 * [![Releases](https://img.shields.io/github/v/release/notablehealth/terraform-google-gke-eso-namespace)](https://github.com/notablehealth/terraform-google-gke-eso-namespace/releases)
 *
 * [Terraform Module Registry](https://registry.terraform.io/modules/notablehealth/gke-eso-namespace/google)
 *
 * Setup External Secrets Operator (ESO) in a GKE namespace
 *
 * ## Module sets up a Kubernetes namespace for ESO
 *
 * - Create GCP service account
 * - Create k8 namespace
 * - Create Kubernetes secret with service account credentials for ESO
 * - Create ESO secret store
 * - Create ESO namespace secret rule
 * - Create ESO shared secret rules
 *
 * ## Limitations
 *
 * - Kubernetes secrets are limited to 1 MB
 *
 * ## Provider setup
 *
 * Access GKE cluster with DNS endpoint
 *
 * ``` hcl
 * data "google_client_config" "self" {}
 * data "google_container_cluster" "self" {
 *   name     = var.cluster_name
 *   location = var.cluster_location
 *   project  = var.project_id
 * }
 * provider "kubernetes" {
 *   host  = "https://${data.google_container_cluster.self.control_plane_endpoints_config[0].dns_endpoint_config[0].endpoint}"
 *   token = data.google_client_config.self.access_token
 * }
 * ```
 *
 */

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest

###--------------------------------
### GCP Service Account
###--------------------------------
resource "google_service_account" "self" {
  account_id   = "${var.gcsm_secret_prefix}${var.namespace}-sa"
  description  = "Permissions for ESO to access secrets for ${var.namespace}"
  display_name = "ESO Secret Access for ${var.namespace}"
  project      = var.project_id
}
# Grant permissions to service account
locals {
  # Allow k8-global, k8-namespace, and legacy prefixes (namespace, {namespace with _}, global)
  prefixes = [
    "${var.gcsm_secret_prefix}${var.namespace}",
    "${var.gcsm_secret_prefix}${var.shared_prefix}",
    replace(var.namespace, "/[_-]/", "_"),
    replace(var.namespace, "/[_-]/", "-"),
    var.shared_prefix,
  ]
  expression = join(" || ", [
    for prefix in local.prefixes : "resource.name.startsWith(\"projects/${var.project_number}/secrets/${prefix}${var.secret_separator}\")"
  ])
}
resource "google_project_iam_member" "secretAccessor" {
  role    = "roles/secretmanager.secretAccessor"
  project = var.project_id
  member  = google_service_account.self.member

  condition {
    title       = "secret_manager_accessor"
    description = "Service Account for accessing secrets with certain prefix"
    expression  = (local.expression)
  }
}

resource "google_project_iam_member" "viewer" {
  role    = "roles/secretmanager.viewer"
  project = var.project_id
  member  = google_service_account.self.member
}

resource "google_service_account_key" "self" {
  service_account_id = google_service_account.self.name
}
# Add to secret manager - Optional
resource "google_secret_manager_secret" "self" {
  secret_id = "${var.gcsm_secret_prefix}${var.namespace}-sa"
  project   = var.project_id
  # labels # terraform, kubernetes, eso
  labels = {
    namespace = var.namespace
    service   = "eso"
  }
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "self" {
  secret      = google_secret_manager_secret.self.id
  secret_data = base64decode(google_service_account_key.self.private_key)
}

# Add secret to k8 namespace for ESO
resource "kubernetes_secret" "sa" {
  metadata {
    name      = "${var.gcsm_secret_prefix}${var.namespace}-sa"
    namespace = var.namespace
  }
  data = {
    secret-access-credentials = base64decode(google_service_account_key.self.private_key)
  }
  type = "Opaque"
  depends_on = [
    google_service_account_key.self,
    kubernetes_namespace.self
  ]
}
###--------------------------------
### Define k8 namespace
###--------------------------------
resource "kubernetes_namespace" "self" {
  metadata {
    name = var.namespace
  }
}
# Manifest functions need terraform >=1.8 or opentofu
# Will need custom terrateam workflow to define "engine"
#   tf code should override, might not need
# manifest_decode = yaml to object
# manifest_encode = object to yaml
# Try yaml functions
#   yamldecode("")
# or https://github.com/jrhouston/tfk8s but is a cli
###--------------------------------
### ESO secret store manifest
###--------------------------------
resource "kubernetes_manifest" "eso_secret_store" {
  manifest = yamldecode(templatefile("${path.module}/templates/k8-eso-secret-store.yaml.tmpl", {
    k8_namespace    = var.namespace
    project_id      = var.project_id
    service_account = "${var.gcsm_secret_prefix}${var.namespace}-sa"
  }))
  #field_manager {
  #  name = "external-secrets"
  #}
  # wait {}
  # timeouts {}
  depends_on = [
    kubernetes_secret.sa
  ]
}
resource "local_file" "k8_eso_secret_store" {
  count = var.local_manifests ? 1 : 0
  content = templatefile("${path.module}/templates/k8-eso-secret-store.yaml.tmpl", {
    k8_namespace    = var.namespace
    project_id      = var.project_id
    service_account = "${var.gcsm_secret_prefix}${var.namespace}-sa"
  })
  filename        = "${path.module}/manifests/${var.project_id}/${var.namespace}/secret-store.yaml"
  file_permission = "0644"
}

###--------------------------------
### ESO namespace secrets manifest
###--------------------------------
resource "kubernetes_manifest" "eso_namespace_secrets" {
  manifest = yamldecode(templatefile("${path.module}/templates/k8-eso-secret-rule.yaml.tmpl", {
    k8_namespace       = var.namespace
    k8_secret          = var.namespace_secret_name
    gcsm_secret_prefix = var.gcsm_secret_prefix
  }))
  depends_on = [kubernetes_manifest.eso_secret_store]
}
resource "local_file" "eso_namespace_secrets" {
  count = var.local_manifests ? 1 : 0
  content = templatefile("${path.module}/templates/k8-eso-secret-rule.yaml.tmpl", {
    k8_namespace       = var.namespace
    k8_secret          = var.namespace_secret_name
    gcsm_secret_prefix = var.gcsm_secret_prefix
  })
  filename        = "${path.module}/manifests/${var.project_id}/${var.namespace}/secrets-namespace.yaml"
  file_permission = "0644"
}

###--------------------------------
### ESO shared secrets manifest
###--------------------------------
locals {
  shared_header = templatefile("${path.module}/templates/k8-eso-secret-header.yaml.tmpl", {
    k8_namespace = var.namespace
    k8_secret    = var.shared_secret_name
  })
  shared_keys = [
    for key in var.shared_secrets : templatefile("${path.module}/templates/k8-eso-secret-key.yaml.tmpl", {
      k8_key     = key
      gcp_secret = "${var.gcsm_secret_prefix}${var.shared_prefix}${var.secret_separator}${key}"
  })]
  shared_manifest = join("\n", concat([local.shared_header], local.shared_keys))
}
resource "kubernetes_manifest" "eso_shared_secrets" {
  manifest   = yamldecode(local.shared_manifest)
  depends_on = [kubernetes_manifest.eso_secret_store]
}
resource "local_file" "eso_shared_secrets" {
  count           = var.local_manifests ? 1 : 0
  content         = local.shared_manifest
  filename        = "${path.module}/manifests/${var.project_id}/${var.namespace}/secrets-shared.yaml"
  file_permission = "0644"
}
