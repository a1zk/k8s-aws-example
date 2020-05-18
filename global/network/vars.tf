#Provider
variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

#VPC 
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "global-vpc"
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}
variable "enable_nat_gateway" {
  type    = bool
  default = true
}
variable "single_nat_gateway" {
  type    = bool
  default = true
}
variable "one_nat_gateway_per_az" {
  type    = bool
  default = false
}