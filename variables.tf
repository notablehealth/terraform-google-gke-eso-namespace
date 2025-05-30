variable "cluster_location" {
  description = "GKE cluster location"
  type        = string
  default     = "us-central1"
}
variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}
variable "gcpsm_secret_prefix" {
  description = "Prefix for GCPSM secrets"
  type        = string
  default     = "k8-"
}
variable "namespace" {
  description = "The name of the Kubernetes namespace to manage."
  type        = string
}
variable "namespace_secret_name" {
  description = "Kubernetes namespace secret name."
  type        = string
  default     = "all"
}
variable "annotations" {
  description = "Namespace annotations"
  type        = map(string)
  default     = {}
}
variable "labels" {
  description = "Namespace labels"
  type        = map(string)
  default     = {}
}
variable "local_manifests" {
  description = "Create local manifests? Mostly for debugging"
  type        = bool
  default     = false
}
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "project_number" {
  description = "GCP Project Number"
  type        = string
}
variable "shared_prefix" {
  description = "GCPSM secret prefix for shared secrets"
  type        = string
  default     = "global"
}
variable "shared_secret_name" {
  description = "Kubernetes shared secret name."
  type        = string
  default     = "global"
}
variable "secret_separator" {
  description = "Separator for GCPSM secrets between namespace and secret key"
  type        = string
  default     = "__"
}
variable "shared_secrets" {
  description = "Shared secrets list"
  type        = list(string)
  default     = []
}
variable "service_account_cluster_prefix" {
  description = "Optional shorter prefix to use for the service account ID instead of the full cluster name"
  type        = string
  default     = null
}
