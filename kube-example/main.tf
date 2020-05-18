#Retrive state from our vpc 
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state-ce67g"
    key    = "global_network"
    region = "us-east-1"
  }
}
locals {
  vpc                 = data.terraform_remote_state.network.outputs.vpc_id
  private_subnets_ids = data.terraform_remote_state.network.outputs.private_subnets_ids
  public_subnets_ids  = data.terraform_remote_state.network.outputs.public_subnets_ids
  public_subnets      = data.terraform_remote_state.network.outputs.public_subnets
  private_subnets     = data.terraform_remote_state.network.outputs.private_subnets
  azs                 = data.terraform_remote_state.network.outputs.azs

}
locals {
  all_subnets = concat(local.public_subnets, local.private_subnets)
}

locals {
  common_tags = {
    Service    = "k8s"
    Enviroment = "dev"
  }
}

module "k8s" {
  source = "../modules/k8s"

  cluster_name            = var.cluster_name
  vpc_id                  = local.vpc
  elb_api_port            = var.elb_api_port
  k8s_secure_api_port     = var.k8s_secure_api_port
  public_subnet_ids       = local.public_subnets_ids
  private_subnet_id       = local.private_subnets_ids
  aws_avail_zones         = local.azs
  private_key_file        = var.private_key_file
  public_key_file         = var.public_key_file
  allowed_ssh_cidr_blocks = concat(var.allowed_ssh_cidr_blocks, local.all_subnets)
  bastion_size            = var.bastion_size
  bastion_num             = var.bastion_num
  pod_network_cidr_block  = var.pod_network_cidr_block
  master_instance_type    = var.master_instance_type
  num_workers             = var.num_workers
  worker_instance_type    = var.worker_instance_type
  tags                    = local.common_tags



}





