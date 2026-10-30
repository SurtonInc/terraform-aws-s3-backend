# AWS S3 state backend

Create an S3 bucket for Terraform or OpenTofu state, with versioning, AES256
server-side encryption, and all four S3 public access blocks enabled.

The module provisions the bucket. Configure an S3 backend separately in each
project that will use it. One bucket can hold state for several projects; give
each project and environment a distinct state `key`.

## Requirements

| Requirement | Version |
| --- | --- |
| Terraform or OpenTofu | >= 1.10.0 |
| AWS provider (`hashicorp/aws`) | >= 6.0.0 |

Configure the AWS provider in your root module. Credentials can come from the
standard AWS environment variables, shared profiles, or an assumed role. The
module inherits the provider's account and region.

## Usage

Add this to a dedicated bootstrap root configuration:

```hcl
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "state_storage" {
  source  = "SurtonInc/s3-backend/aws"
  version = "~> 1.0"

  tags = {
    ManagedBy = "Terraform"
  }
}

output "s3_bucket_name" {
  value = module.state_storage.s3_bucket_name
}

output "s3_bucket_region" {
  value = module.state_storage.s3_bucket_region
}
```

The short source address uses your CLI's default registry: Terraform Registry
for Terraform and OpenTofu Registry for OpenTofu. If your registry has not indexed
the module yet, install directly from GitHub with the following source and omit
the `version` argument:

```hcl
source = "git::https://github.com/SurtonInc/terraform-aws-s3-backend.git?ref=v1.0.0"
```

Run the bootstrap configuration with local state or an existing backend:

```sh
terraform init
terraform plan
terraform apply
terraform output -raw s3_bucket_name
```

For OpenTofu, replace `terraform` with `tofu` in these commands.

By default, the bucket is named `terraform-states-<account-id>-<region>`. This
allows one default bucket per AWS account and region. To create another, set
`bucket_name` to a globally unique S3 bucket name. Changing the name or provider
region for existing resources can require a new bucket and state migration.

See the [complete example](https://github.com/SurtonInc/terraform-aws-s3-backend/tree/main/examples/complete)
for a runnable configuration using a local module source.

## Configure a project's backend

After the bucket exists, add this to the root configuration of a project that
will store its state there. Replace the bucket and region with the bootstrap
outputs and choose a unique state key:

```hcl
terraform {
  backend "s3" {
    bucket       = "terraform-states-123456789012-us-east-1"
    key          = "my-app/production/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

Run `terraform init` for a new project. If the project already has state, back it
up first, then run `terraform init -migrate-state` and review the migration
prompt. Use `tofu init` or `tofu init -migrate-state` with OpenTofu.

Backend initialization happens before resources are created. The backend must
point to an existing bucket and cannot reference `module.state_storage` outputs.
Copy the output values into the backend configuration, or supply them through
`init -backend-config=PATH` using a separate backend configuration file.

The bootstrap configuration can also migrate its own state into the bucket
once it has been created. Keep a secure backup of its state before migration.

### State locking and access

`use_lockfile = true` enables native S3 state locking in Terraform and OpenTofu
1.10 or later. The lock object lives beside the state object as `<key>.tflock`.
No DynamoDB table is required.

This module does not create IAM roles or policies. For the backend configuration
above, the identity running Terraform or OpenTofu needs:

- `s3:ListBucket` on the state bucket.
- `s3:GetObject` and `s3:PutObject` on its state key.
- `s3:GetObject`, `s3:PutObject`, and `s3:DeleteObject` on its lock key.

Additional permissions and object paths may be needed for CLI workspaces,
backend options, or state migration. The identity provisioning this module also
needs permissions to read its AWS account and manage the bucket, versioning,
encryption, public access settings, and tags. Backend credentials are resolved
separately from the AWS provider; an `assume_role` or profile configured only on
the provider does not configure backend authentication.

See the [Terraform S3 backend documentation](https://developer.hashicorp.com/terraform/language/backend/s3)
and [OpenTofu S3 backend documentation](https://opentofu.org/docs/language/settings/backends/s3/)
for complete permissions and authentication options.

## Inputs

| Name | Description | Type | Default |
| --- | --- | --- | --- |
| `bucket_name` | Globally unique S3 bucket name. `null` uses `terraform-states-<account-id>-<region>`. | `string` | `null` |
| `tags` | Tags applied to the S3 bucket, in addition to provider default tags. | `map(string)` | `{}` |

## Outputs

| Name | Description |
| --- | --- |
| `s3_bucket_name` | Name of the state bucket. |
| `s3_bucket_arn` | ARN of the state bucket. |
| `s3_bucket_region` | AWS region of the state bucket. |

## Storage behavior

- Versioning retains previous state versions for recovery. No lifecycle policy
  removes old versions, so storage grows with state history.
- Encryption uses S3-managed keys (`AES256`). This module does not create a KMS key.
- Public access is blocked. Access for specific AWS identities remains governed
  by IAM and any policies managed outside this module.
- The module does not enable `force_destroy`. Deleting a bucket containing state
  or historical versions fails until those objects are removed. An empty bucket
  can still be destroyed; protect the bootstrap configuration accordingly.

## Migrating from `tf-s3-backend`

The former repository was a standalone root configuration. Version 1.0.0 uses
caller-owned AWS provider configuration and replaces `aws_profile` and
`aws_region` module inputs with the provider's `profile` and `region` settings.
The default bucket name, resource names, and output names are preserved.

If you continue running this checkout as a root configuration, add an AWS
provider block in that root and use the same account and region as before. If
you move existing resources from a root configuration into a child module,
resource addresses change. Back up state, map all managed resources with
`moved` blocks or state commands, and review a plan before applying. A repository
rename alone does not move resources into the module or migrate state.

## License

MIT. Originally adapted from the
[Gruntwork introductory S3 backend example](https://github.com/gruntwork-io/intro-to-terraform/tree/master/s3-backend).
