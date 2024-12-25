
variable "gcsm_secret_prefix" {
  description = "Prefix for GCSM secrets"
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
  description = "GCSM secret prefix for shared secrets"
  type        = string
  default     = "global"
}
variable "shared_secret_name" {
  description = "Kubernetes shared secret name."
  type        = string
  default     = "global"
}
variable "secret_separator" {
  description = "Separator for GCSM secrets between namespace and secret key"
  type        = string
  default     = "__"
}
variable "shared_secrets" {
  description = "Shared secrets list"
  type        = list(string)
  default     = []
}
