terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

provider "aws" {
  alias  = "secondary"
  region = "eu-west-1"
}

module "state_storage" {
  source = "../../.."
  count  = 2

  providers = {
    aws = aws.secondary
  }

  bucket_name = "example-counted-state-${count.index}"
}

output "bucket_regions" {
  value = [for storage in module.state_storage : storage.s3_bucket_region]
}
