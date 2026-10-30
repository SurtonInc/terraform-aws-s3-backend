# Changelog

## [Unreleased]

## [1.0.0] - 2026-10-30

### Added

- Registry module packaging, explicit tool and AWS provider requirements, and a complete bootstrap example.
- Optional bucket name and tags inputs.
- Mocked provider tests for storage settings and provider inheritance.

### Changed

- AWS credentials and region are configured by the calling root module.
- Terraform and OpenTofu 1.10 or later and AWS provider 6.0 or later are required.
- README now documents registry installation, bootstrap, native S3 locking, permissions, outputs, and migration from the standalone configuration.

### Removed

- Module-owned AWS provider configuration and the `aws_profile` and `aws_region` inputs.
- Root dependency lock file; consuming root configurations own provider selection.

[Unreleased]: https://github.com/SurtonInc/terraform-aws-s3-backend/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/SurtonInc/terraform-aws-s3-backend/releases/tag/v1.0.0
