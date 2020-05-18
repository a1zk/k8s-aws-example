variable "cluster_name" {
  description = "K8s cluster name"

}
variable "vpc_id" {
  description = "Your VPC id"
}
variable "tags" {
  description = "K8s tags"
}

variable "elb_api_port" {
  description = "Port for AWS ELB"
}

variable "k8s_secure_api_port" {
  description = "Secure Port of K8S API Server"
}

variable "aws_avail_zones" {
  description = "Availability Zones Used"
  type        = list
}
variable "private_key_file" {
  type        = string
  description = "Filename of the private key of a key pair on your local machine. This key pair will allow to connect to the Bastion Host with SSH."
  default     = "~/.ssh/id_rsa"
}
variable "public_key_file" {
  type        = string
  description = "Filename of the public key of a key pair on your local machine. This key pair will allow to connect to the nodes of the cluster with SSH."
  default     = "~/.ssh/id_rsa.pub"
}

variable "allowed_ssh_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks from which it is allowed to make SSH connections to the Bastion Host(s) By default, SSH connections are allowed from everywhere."
  default     = ["0.0.0.0/0"]
}

variable "bastion_size" {
  type        = string
  description = "Bastion Host type"
  default     = "t2.micro"
}

variable "bastion_num" {
  description = "Number of Bastion host"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Lists of publick Subnets"
}

variable "pod_network_cidr_block" {
  type        = string
  description = "*Optional* Pods network CIDR"
}

variable "master_instance_type" {
  type        = string
  description = "Master Host type"
  default     = "t2.medium"
}
variable "private_subnet_id" {
  type        = list(string)
  description = "VPC private subnet"

}
variable "num_workers" {
  type        = number
  description = "Number of workes node"
  default     = 2


}
variable "worker_instance_type" {
  type        = string
  description = "Worker Host type"
  default     = "t2.small"

}









