variable "bucket_name" {
  description = "S3 bucket name. Defaults to terraform-states-<account-id>-<region>; a custom name must be globally unique."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the S3 bucket."
  type        = map(string)
  default     = {}
  nullable    = false
}
