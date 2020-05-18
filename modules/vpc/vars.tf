variable "vpc_name" {
  type        = string
  description = "VPC name"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnets"

}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnets"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enabeling NAT gateway"
}

variable "single_nat_gateway" {
  type        = bool
  description = "Enabeling single NAT gateway"
}

variable "one_nat_gateway_per_az" {
  type        = bool
  description = "Enable NAT gateway per AZ"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostname"
}

variable "tags" {
  type        = map(string)
  description = "Bunch of tags"
}








