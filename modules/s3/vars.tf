variable "region" {
    type = string
    description = "S3 region"
  
}

variable "bucket_name" {
    type = string
    description = "bucket name"
  
}

variable "acl" {
    type = string
    description = "ACL type"
    default = "private"
  
}

variable "versioning" {
    type = bool
    description = "Enablening versioning"
    default = true
  
}


