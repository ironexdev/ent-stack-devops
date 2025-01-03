terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
  }
}

locals {
  s3_origin_id = "ent-origin"
}

# Define the OAC resource
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.project_name}-${var.region_shorthand}-oac"
  description                       = "OAC for ${var.project_name} CloudFront distribution"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  http_version        = "http2and3"
  price_class         = "PriceClass_All"

  origin {
    domain_name = var.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    # Associate the OAC with the CloudFront origin
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  # Default cache behavior - requires signed URLs
  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    trusted_key_groups     = [var.cloudfront_key_group_id]

    default_ttl = 86400    // 1 day
    min_ttl     = 300      // 5 min
    max_ttl     = 31536000 // 1 year
    compress    = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      cookies {
        forward = "none"
      }

      query_string = true
    }
  }

  # Cache behavior for "assets" folder - no signed URLs required
  ordered_cache_behavior {
    path_pattern           = "assets/*"
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    trusted_key_groups     = [] # No key group means no signed URLs required

    default_ttl = 86400    // 1 day
    min_ttl     = 300      // 5 min
    max_ttl     = 31536000 // 1 year
    compress    = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${var.project_name}-${var.region_shorthand}-cloudfront-distribution"
  }
}
