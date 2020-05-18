variable "region" {
    default = "us-east-1"
}

variable "dns_name" {}
variable "bucket_name" {}
variable "node_num" {}
variable "master_num" {}
variable "master_type" {
    default = "t2.medium"
}
variable "node_type" {
    default = "t2.medium"
}
variable "dns_type" {
    default = "private"
}





