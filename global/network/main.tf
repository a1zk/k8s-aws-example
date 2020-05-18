# Global network
locals {
  common_tags = {
    Service    = "VPC"
    Enviroment = "Global"
  }
}
data "aws_availability_zones" "azs" {
  state = "available"
}

module "vpc" {
  source = "../../modules/vpc/"

  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name

  azs = data.aws_availability_zones.azs.names
  private_subnets = [
    for num in range(length(data.aws_availability_zones.azs.names)) :
    cidrsubnet(var.vpc_cidr, 8, num +1)
  ]
  public_subnets = [
    for num in range(length(data.aws_availability_zones.azs.names)) :
    cidrsubnet(var.vpc_cidr, 8, num +10)
  ]

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway      = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  enable_dns_hostnames   = var.enable_dns_hostnames

  tags = local.common_tags

}