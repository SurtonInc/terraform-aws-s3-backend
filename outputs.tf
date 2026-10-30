output "s3_bucket_name" {
  description = "Name of the S3 state bucket."
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 state bucket."
  value       = aws_s3_bucket.terraform_state.arn
}

output "s3_bucket_region" {
  description = "AWS region of the S3 state bucket."
  value       = data.aws_region.current.region
}
