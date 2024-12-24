
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# terraform-google-gke-eso-namespace

[![Releases](https://img.shields.io/github/v/release/notablehealth/terraform-google-gke-eso-namespace)](https://github.com/notablehealth/terraform-google-gke-eso-namespace/releases)

[Terraform Module Registry](https://registry.terraform.io/modules/notablehealth/gke-eso-namespace/google)

Setup ESO in a GKE namespace

## Module sets up a Kubernetes namespace for ESO

- Create GCP service account
- Create k8 namespace
- Create Kubernetes secret with service account credentials for ESO
- Create ESO secret store
- Create ESO secret rule

## Limitations

- Kubernetes secrets are limited to 1 MB

## Provider setup

Access GKE cluster with DNS endpoint

``` hcl
data "google_client_config" "self" {}
data "google_container_cluster" "self" {
  name     = var.cluster_name
  location = var.cluster_location
  project  = var.project_id
}
provider "kubernetes" {
  host  = "https://${data.google_container_cluster.self.control_plane_endpoints_config[0].dns_endpoint_config[0].endpoint}"
  token = data.google_client_config.self.access_token
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
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.14.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.35.1 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_iam_member.secretAccessor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret.self](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.self](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.self](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.self](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [kubernetes_manifest.eso_secret_rule](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.eso_secret_store](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.self](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.sa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [local_file.eso_secret_rule](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.k8_eso_secret_store](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gcsm_secret_prefix"></a> [gcsm\_secret\_prefix](#input\_gcsm\_secret\_prefix) | Prefix for GCSM secrets | `string` | `"k8-"` | no |
| <a name="input_local_manifests"></a> [local\_manifests](#input\_local\_manifests) | Create local manifests? | `bool` | `true` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The name of the Kubernetes namespace to manage. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | GCP Project Number | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sample_output"></a> [sample\_output](#output\_sample\_output) | output value description |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
