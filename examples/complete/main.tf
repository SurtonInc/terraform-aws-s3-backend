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
  source = "../.."

  tags = {
    ManagedBy = "Terraform"
  }
}

output "s3_bucket_name" {
  value = module.state_storage.s3_bucket_name
}

output "s3_bucket_arn" {
  value = module.state_storage.s3_bucket_arn
}

output "s3_bucket_region" {
  value = module.state_storage.s3_bucket_region
}
