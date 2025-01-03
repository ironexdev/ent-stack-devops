variable "project_name" {
  description = "The project name"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the distribution"
  type        = string
}

variable "origin_domain" {
  description = "The domain name of the origin"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  type        = string
}

variable "origin_http_port" {
  description = "The HTTP port of the origin"
  type        = number
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID for the domain"
  type        = string
}
