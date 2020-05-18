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
  public_subnets_ids  = data.terraform_remote_state.network.outputs.public_subnets_ids
  public_subnets      = data.terraform_remote_state.network.outputs.public_subnets
  azs                 = data.terraform_remote_state.network.outputs.azs

}
locals {
  # Kops has the protection of even number  muster workers and here we will check if number even, we will add +1 node for a quorum
  master_nodes = var.master_num %2 == 0 ? var.master_num +1 : var.master_num
}
resource "random_string" "s3_prefix" {
  length  = 6
  special = false
  upper   = false
}

module "kops-k8s"{
    source = "../modules/k8s-kops"

    vpc_id      = local.vpc
    region      = var.region
    dns_name    = var.dns_name
    bucket_name = "${var.bucket_name}-${random_string.s3_prefix.result}"
    master_azs  = join(",", slice(local.azs, 0, local.master_nodes))
    node_azs    = join(",", slice(local.azs, 0, var.node_num))
    subnets     = join(",", slice(local.public_subnets_ids, 0, var.node_num >= local.master_nodes ? var.node_num: local.master_nodes))
    node_num    = var.node_num
    master_num  = local.master_nodes
    master_type = var.master_type
    node_type   = var.node_type
    dns_type    = var.dns_type
    



}