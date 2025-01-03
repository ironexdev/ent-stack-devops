output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.distribution.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.distribution.domain_name
}