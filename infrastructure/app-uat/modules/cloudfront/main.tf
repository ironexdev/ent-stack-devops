resource "aws_cloudfront_distribution" "distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${var.domain_name}"
  default_root_object = ""

  aliases = [var.domain_name]

  origin {
    domain_name = var.origin_domain
    origin_id   = "${var.project_name}-origin-${var.domain_name}"

    custom_origin_config {
      http_port              = var.origin_http_port
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "${var.project_name}-origin-${var.domain_name}"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.domain_name}-reverse-proxy"
  }
}

# Route53 DNS Record
resource "aws_route53_record" "cloudfront_alias" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
