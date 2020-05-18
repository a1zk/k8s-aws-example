module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.33.0"


  name = var.vpc_name
  cidr = var.vpc_cidr


  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway      = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  enable_dns_hostnames   = var.enable_dns_hostnames

  tags = var.tags


}