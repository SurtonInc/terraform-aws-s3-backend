# S3 backend for Terraform

Creates a s3 bucket to use as a terraform backend.

- s3_bucket_name = <account_id>-terraform-states

## inputs

```
# add to terraform.tfvars
aws_profile = "example-profile"
aws_region  = "us-east-2"
```

## usage

```shell
# Dry-run
terraform init
terraform plan

# apply the change
terraform apply
```
