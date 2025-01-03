output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
