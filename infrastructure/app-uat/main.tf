data "aws_region" "current" {}

locals {
  region = data.aws_region.current.name
}

resource "aws_acm_certificate" "tls_cert" {
  domain_name       = var.frontend_domain_name
  subject_alternative_names = [var.backend_domain_name]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "tls_validation" {
  for_each = {
    for dvo in aws_acm_certificate.tls_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "tls_cert_validation" {
  certificate_arn         = aws_acm_certificate.tls_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.tls_validation : record.fqdn]
}

module "vpc" {
  source               = "./modules/vpc"
  project_name         = var.project_name
  region_shorthand     = var.region_shorthand
  availability_zone1   = var.availability_zone1
  availability_zone2   = var.availability_zone2
  public_subnet1_cidr  = var.public_subnet1_cidr
  private_subnet1_cidr = var.private_subnet1_cidr
  public_subnet2_cidr  = var.public_subnet2_cidr
  private_subnet2_cidr = var.private_subnet2_cidr
  vpc_cidr             = var.vpc_cidr
}

module "ecs" {
  source           = "./modules/ecs"
  project_name     = var.project_name
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet1_id

  ec2_instance_ami              = var.ec2_instance_ami
  ec2_instance_type             = var.ec2_instance_type
  backend_container_definition  = var.backend_container_definition
  backend_port                  = var.backend_port
  frontend_container_definition = var.frontend_container_definition
  frontend_port                 = var.frontend_port
  database_container_definition = var.database_container_definition
  database_port                 = var.database_port
}

resource "aws_route53_record" "ecs_frontend_origin" {
  zone_id = var.route53_zone_id
  name    = "ecs-frontend.${var.frontend_domain_name}"
  type    = "A"

  ttl = 60
  records = [module.ecs.ecs_instance_eip]
}

resource "aws_route53_record" "ecs_backend_origin" {
  zone_id = var.route53_zone_id
  name    = "ecs-backend.${var.backend_domain_name}"
  type    = "A"

  ttl = 60
  records = [module.ecs.ecs_instance_eip]
}

module "cloudfront_frontend" {
  source              = "./modules/cloudfront"
  project_name        = var.project_name
  domain_name         = var.frontend_domain_name
  origin_domain       = "ecs-frontend.${var.frontend_domain_name}"
  acm_certificate_arn = aws_acm_certificate_validation.tls_cert_validation.certificate_arn
  origin_http_port    = var.frontend_port
  route53_zone_id     = var.route53_zone_id
}

module "cloudfront_backend" {
  source              = "./modules/cloudfront"
  project_name        = var.project_name
  domain_name         = var.backend_domain_name
  origin_domain       = "ecs-backend.${var.backend_domain_name}"
  acm_certificate_arn = aws_acm_certificate_validation.tls_cert_validation.certificate_arn
  origin_http_port    = var.backend_port
  route53_zone_id     = var.route53_zone_id
}
