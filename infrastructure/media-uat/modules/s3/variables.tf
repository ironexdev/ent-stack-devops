variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "region_shorthand" {
  description = "The shorthand for the region"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  type        = string
}
