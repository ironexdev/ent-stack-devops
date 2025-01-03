module "ent_s3" {
  source = "./modules/s3"

  bucket_name                 = var.bucket_name
  project_name                = var.project_name
  region_shorthand            = var.region_shorthand
  cloudfront_distribution_arn = module.ent_cloudfront.cloudfront_distribution_arn

  providers = {
    aws = aws
  }
}

module "ent_cloudfront" {
  source = "./modules/cloudfront"

  project_name                = var.project_name
  region_shorthand            = var.region_shorthand
  bucket_regional_domain_name = module.ent_s3.bucket_regional_domain_name
  cloudfront_key_group_id     = var.cloudfront_key_group_id

  providers = {
    aws = aws
  }
}