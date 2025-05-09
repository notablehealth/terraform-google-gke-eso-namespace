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
 * - Create Kubernetes service account for ESO
 * - Create ESO secret store
 * - Create ESO namespace secret rule
 * - Create ESO shared secret rules
 *
 * ## Limitations
 *
 * - Kubernetes secrets are limited to 1 MB
 *
 * ## Provider setup required in calling module
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
 * provider "kubectl" {
 *   host             = "https://${data.google_container_cluster.self.control_plane_endpoints_config[0].dns_endpoint_config[0].endpoint}"
 *   token            = data.google_client_config.self.access_token
 *   load_config_file = false
 * }
 * provider "kubernetes" {
 *   host  = "https://${data.google_container_cluster.self.control_plane_endpoints_config[0].dns_endpoint_config[0].endpoint}"
 *   token = data.google_client_config.self.access_token
 * }
 * terraform {
 *   required_providers {
 *     kubectl = {
 *       source  = "gavinbunney/kubectl"
 *       version = ">= 1.18.0"
 *     }
 *   }
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
  account_id   = "${var.gcpsm_secret_prefix}${coalesce(var.service_account_cluster_prefix, var.cluster_name)}-${var.namespace}"
  description  = "Permissions for ESO to access secrets for ${var.namespace}"
  display_name = "ESO Secret Access for ${var.namespace}"
  project      = var.project_id
}
# Grant permissions to service account
locals {
  # Allow k8-global, k8-namespace, and legacy prefixes (namespace, {namespace with _}, global)
  prefixes = [
    "${var.gcpsm_secret_prefix}${var.namespace}",
    "${var.gcpsm_secret_prefix}${var.shared_prefix}",
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

## Create K8 service account
resource "kubernetes_service_account" "self" {
  metadata {
    name      = "eso-${var.namespace}"
    namespace = var.namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.self.email
    }
    #labels = {}
  }
  #automount_service_account_token = false
  depends_on = [
    kubernetes_namespace.self
  ]
}
## Allow ESO to impersonate the service account
resource "google_service_account_iam_binding" "k8-service-account-iam" {
  service_account_id = google_service_account.self.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_service_account.self.id}]",
  ]
  depends_on = [
    google_service_account.self,
    kubernetes_service_account.self,
  ]
}

###--------------------------------
### Define k8 namespace
###--------------------------------
resource "kubernetes_namespace" "self" {
  metadata {
    annotations = var.annotations
    labels      = var.labels
    name        = var.namespace
  }
  lifecycle {
    prevent_destroy = true
  }
}
# https://github.com/jrhouston/tfk8s cli to convert k8s yaml to terraform
###--------------------------------
### ESO secret store manifest
###--------------------------------
# Kubernetes provider 2.35.1
#   kubernetes_manifest could not manage ESO secret store with Workload Identity
# Switched to kubectl provider
resource "kubectl_manifest" "eso_secret_store" {
  yaml_body = templatefile("${path.module}/templates/k8-eso-secret-store-wi.yaml.tmpl", {
    cluster_location = var.cluster_location
    cluster_name     = var.cluster_name
    k8_namespace     = var.namespace
    k8_sa_namespace  = replace(kubernetes_service_account.self.id, "/^(.*)[/].*$/", "$1")
    project_id       = var.project_id
    service_account  = replace(kubernetes_service_account.self.id, "/^.*[/](.*)$/", "$1")
  })
  depends_on = [
    kubernetes_service_account.self
  ]
}
resource "local_file" "k8_eso_secret_store" {
  count = var.local_manifests ? 1 : 0
  content = templatefile("${path.module}/templates/k8-eso-secret-store-wi.yaml.tmpl", {
    cluster_location = var.cluster_location
    cluster_name     = var.cluster_name
    k8_namespace     = var.namespace
    k8_sa_namespace  = replace(kubernetes_service_account.self.id, "/^(.*)[/].*$/", "$1")
    project_id       = var.project_id
    service_account  = replace(kubernetes_service_account.self.id, "/^.*[/](.*)$/", "$1")
  })
  filename        = "${path.module}/manifests/${var.project_id}/${var.namespace}/secret-store.yaml"
  file_permission = "0644"
}

###--------------------------------
### ESO namespace secrets manifest
###--------------------------------
resource "kubectl_manifest" "eso_namespace_secrets" {
  yaml_body = templatefile("${path.module}/templates/k8-eso-secret-rule.yaml.tmpl", {
    k8_namespace        = var.namespace
    k8_secret           = var.namespace_secret_name
    gcpsm_secret_prefix = var.gcpsm_secret_prefix
  })
  depends_on = [kubectl_manifest.eso_secret_store]
}
resource "local_file" "eso_namespace_secrets" {
  count = var.local_manifests ? 1 : 0
  content = templatefile("${path.module}/templates/k8-eso-secret-rule.yaml.tmpl", {
    k8_namespace        = var.namespace
    k8_secret           = var.namespace_secret_name
    gcpsm_secret_prefix = var.gcpsm_secret_prefix
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
      gcp_secret = "${var.gcpsm_secret_prefix}${var.shared_prefix}${var.secret_separator}${key}"
  })]
  shared_manifest = join("\n", concat([local.shared_header], local.shared_keys))
}
resource "kubectl_manifest" "eso_shared_secrets" {
  yaml_body  = local.shared_manifest
  depends_on = [kubectl_manifest.eso_secret_store]
}
resource "local_file" "eso_shared_secrets" {
  count           = var.local_manifests ? 1 : 0
  content         = local.shared_manifest
  filename        = "${path.module}/manifests/${var.project_id}/${var.namespace}/secrets-shared.yaml"
  file_permission = "0644"
}
