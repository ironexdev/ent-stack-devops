terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          "Service" : "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.this.id}/*",
        Condition = {
          "StringEquals" : {
            "AWS:SourceArn" : var.cloudfront_distribution_arn
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${var.region_shorthand}-s3-bucket"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "delete-non-current-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}