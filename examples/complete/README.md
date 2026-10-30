# Complete example

Creates one state bucket in `us-east-1` using the module in this checkout.
Authenticate to AWS using your usual credentials, then run:

```sh
terraform init
terraform plan
terraform apply
```

For OpenTofu, use `tofu` in place of `terraform`.

This example starts with local state so the bucket can be created before an S3
backend is configured. Keep that state secure. See the root README for registry
installation, backend configuration, and state migration.
