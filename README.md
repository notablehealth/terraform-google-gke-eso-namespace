
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# terraform-google-module-template

[![Releases](https://img.shields.io/github/v/release/notablehealth/terraform-google-module-template)](https://github.com/notablehealth/terraform-google-module-template/releases)

[Terraform Module Registry](https://registry.terraform.io/modules/notablehealth/module-template/google)

Template for creating a Terraform module for Google

## Features

- base terraform files
- pre-commit setup
- GitHub actions setup

## Usage

Basic usage of this module is as follows:

```hcl
module "example" {
    source = "notablehealth/<module-name>/google"
    # Recommend pinning every module to a specific version
    # version = "x.x.x"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.51.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sample_input"></a> [sample\_input](#input\_sample\_input) | Simple string variable | `string` | `"sample"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sample_output"></a> [sample\_output](#output\_sample\_output) | output value description |


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
