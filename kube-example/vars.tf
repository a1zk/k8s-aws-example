#provider region
variable "region" {
  default = "us-east-1"
}
variable "cluster_name" {}
variable "elb_api_port" {
  default = 6443
}
variable "k8s_secure_api_port" {
  default = 6443
}

variable "private_key_file" {
  default = "~/.ssh/id_rsa"
}
variable "public_key_file" {
  default = "~/.ssh/id_rsa.pub"
}

variable "allowed_ssh_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "bastion_size" {
  default = "t2.micro"
}

variable "bastion_num" {}

variable "num_workers" {}

variable "pod_network_cidr_block" {
  default = null
}

variable "master_instance_type" {}
variable "worker_instance_type" {}



