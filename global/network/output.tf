output "vpc_name" {
  value = module.vpc.vpc_name
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "azs" {
  value = module.vpc.azs
}

output "private_subnets" {
  value = module.vpc.private_subnets
}
output "public_subnets" {
  value = module.vpc.public_subnets
}

output "natgw_ids" {
  value = module.vpc.natgw_ids
}
output "private_subnets_ids" {
  value = module.vpc.private_subnets_ids
}
output "public_subnets_ids" {
  value = module.vpc.public_subnets_ids
}
