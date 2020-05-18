
variable "region" {
    type = string
    description = "S3 region"
}
variable "vpc_id" {
    type = string
    description = "ID of existing VPC"
  
}

variable "dns_name" {
    type = string
    description = "DNS and cluster name"
}

variable "bucket_name" {
    type = string
    description = "kops state bucket name"
  
}
variable "master_azs" {
    type = string
    description = "AZS for masters nodes"
  
}
variable "node_azs" {
    type = string
    description = "AZS for worke nodes"
  
}
variable "subnets" {
    type = string
    description = "Subnets for nodes"
  
}
variable "node_num" {
    type = number
    description = "Number of worker nodes"
    default = 3
  
}
variable "master_num" {
    type = number
    description = "Number of master nodes"
    default = 1
  
}
variable "master_type" {
    type = string
    description = "Master node type"
    default = "t2.medium"
  
}
variable "node_type" {
    type = string
    description = "Worker node type"
    default = "t2.medium"
  
}
variable "dns_type" {
    type =string
    description = "DNS records type"
    default = "private"
  
}






