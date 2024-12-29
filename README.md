
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# terraform-google-gke-eso-namespace

[![Releases](https://img.shields.io/github/v/release/notablehealth/terraform-google-gke-eso-namespace)](https://github.com/notablehealth/terraform-google-gke-eso-namespace/releases)

[Terraform Module Registry](https://registry.terraform.io/modules/notablehealth/gke-eso-namespace/google)

Setup External Secrets Operator (ESO) in a GKE namespace

## Module sets up a Kubernetes namespace for ESO

- Create GCP service account
- Create k8 namespace
- Create Kubernetes service account for ESO
- Create ESO secret store
- Create ESO namespace secret rule
- Create ESO shared secret rules

## Limitations

- Kubernetes secrets are limited to 1 MB

## Provider setup required in calling module

Access GKE cluster with DNS endpoint

``` hcl
data "google_client_config" "self" {}
data "google_container_cluster" "self" {
  name     = var.cluster_name
  location = var.cluster_location
  project  = var.project_id
}
provider "kubectl" {
  host             = "https://${data.google_container_cluster.self.control_plane_endpoints_config[0].dns_endpoint_config[0].endpoint}"
  token            = data.google_client_config.self.access_token
  load_config_file = false
}
provider "kubernetes" {
  host  = "https://${data.google_container_cluster.self.control_plane_endpoints_config[0].dns_endpoint_config[0].endpoint}"
  token = data.google_client_config.self.access_token
}
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.18.0"
    }
  }
}
```

## Usage

Basic usage of this module is as follows:

```hcl
module "example" {
    source = "notablehealth/<module-name>/google"
    # Recommend pinning every module to a specific version
    # version = "x.x.x"

    # Required variables
    cluster_name =
    namespace =
    project_id =
    project_number =
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.18.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.14.1 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 1.18.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.35.1 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_member.secretAccessor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.self](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.k8-service-account-iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [kubectl_manifest.eso_namespace_secrets](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.eso_secret_store](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.eso_shared_secrets](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.self](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service_account.self](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [local_file.eso_namespace_secrets](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.eso_shared_secrets](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.k8_eso_secret_store](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_location"></a> [cluster\_location](#input\_cluster\_location) | GKE cluster location | `string` | `"us-central1"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | GKE cluster name | `string` | n/a | yes |
| <a name="input_gcpsm_secret_prefix"></a> [gcpsm\_secret\_prefix](#input\_gcpsm\_secret\_prefix) | Prefix for GCPSM secrets | `string` | `"k8-"` | no |
| <a name="input_local_manifests"></a> [local\_manifests](#input\_local\_manifests) | Create local manifests? Mostly for debugging | `bool` | `false` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The name of the Kubernetes namespace to manage. | `string` | n/a | yes |
| <a name="input_namespace_secret_name"></a> [namespace\_secret\_name](#input\_namespace\_secret\_name) | Kubernetes namespace secret name. | `string` | `"all"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | GCP Project Number | `string` | n/a | yes |
| <a name="input_secret_separator"></a> [secret\_separator](#input\_secret\_separator) | Separator for GCPSM secrets between namespace and secret key | `string` | `"__"` | no |
| <a name="input_shared_prefix"></a> [shared\_prefix](#input\_shared\_prefix) | GCPSM secret prefix for shared secrets | `string` | `"global"` | no |
| <a name="input_shared_secret_name"></a> [shared\_secret\_name](#input\_shared\_secret\_name) | Kubernetes shared secret name. | `string` | `"global"` | no |
| <a name="input_shared_secrets"></a> [shared\_secrets](#input\_shared\_secrets) | Shared secrets list | `list(string)` | `[]` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
