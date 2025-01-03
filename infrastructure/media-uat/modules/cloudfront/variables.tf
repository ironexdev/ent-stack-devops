variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "region_shorthand" {
  description = "The shorthand for the region"
  type        = string
}

variable "cloudfront_key_group_id" {
  description = "The ID of the CloudFront key group"
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "The domain name of the regional bucket"
  type        = string
}