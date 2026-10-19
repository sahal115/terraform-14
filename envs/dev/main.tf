# Vpc
module "vpc" {
  source         = "../../modules/vpc"
  vpc-cidr_block = "192.160.0.0/16"
  vpc_name       = "dev-vpc"
}

#frontend

module "frontend" {
  source                 = "../../modules/frontendaws"
  bucket_name            = "frontend.dnc.beauty"
  aws_origin_access_name = "Cross access from cloudfront"
  cert_domain            = "*.dnc.Beauty"
  dns_record             = "frontend.dnc.beauty"
  hosted_zone_name       = "dnc.Beauty"
}

