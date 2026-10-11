module "vpc" {
  source         = "../../modules/vpc"
  vpc-cidr_block = "192.160.0.0/16"
  vpc_name       = "dev-vpc"
}