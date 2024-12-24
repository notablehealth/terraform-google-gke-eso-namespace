
variable "gcsm_secret_prefix" {
  description = "Prefix for GCSM secrets"
  type        = string
  default     = "k8-"
}
variable "namespace" {
  description = "The name of the Kubernetes namespace to manage."
  type        = string
}
variable "local_manifests" {
  description = "Create local manifests?"
  type        = bool
  default     = true
}
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "project_number" {
  description = "GCP Project Number"
  type        = string
}
