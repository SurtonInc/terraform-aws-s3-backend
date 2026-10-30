mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_region" {
    defaults = {
      region = "us-east-1"
    }
  }
}

mock_provider "aws" {
  alias = "secondary"

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_region" {
    defaults = {
      region = "eu-west-1"
    }
  }
}

run "preserves_default_storage" {
  command = apply

  assert {
    condition     = aws_s3_bucket.terraform_state.bucket == "terraform-states-123456789012-us-east-1"
    error_message = "The existing account-and-region bucket name must be preserved."
  }

  assert {
    condition = (
      aws_s3_bucket_versioning.terraform_state.versioning_configuration[0].status == "Enabled" &&
      one(aws_s3_bucket_server_side_encryption_configuration.terraform_state.rule).apply_server_side_encryption_by_default[0].sse_algorithm == "AES256" &&
      aws_s3_bucket_public_access_block.terraform_state.block_public_acls &&
      aws_s3_bucket_public_access_block.terraform_state.block_public_policy &&
      aws_s3_bucket_public_access_block.terraform_state.ignore_public_acls &&
      aws_s3_bucket_public_access_block.terraform_state.restrict_public_buckets
    )
    error_message = "Registry packaging must preserve versioning, encryption, and blocked public access."
  }
}

run "custom_bucket" {
  command = plan

  variables {
    bucket_name = "example-custom-state-bucket"
    tags        = { Environment = "test" }
  }

  assert {
    condition = (
      aws_s3_bucket.terraform_state.bucket == "example-custom-state-bucket" &&
      aws_s3_bucket.terraform_state.tags["Environment"] == "test"
    )
    error_message = "Callers must be able to select a distinct bucket and its tags."
  }
}

run "caller_provider_with_count" {
  command = apply

  module {
    source = "./tests/fixtures/provider-inheritance"
  }

  providers = {
    aws.secondary = aws.secondary
  }

  assert {
    condition     = output.bucket_regions == ["eu-west-1", "eu-west-1"]
    error_message = "Counted module calls must inherit the caller's selected provider and region."
  }
}
