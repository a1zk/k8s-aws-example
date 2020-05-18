module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "1.6.0"
  region = var.region

  bucket = var.bucket_name
  acl    = var.acl
  force_destroy = true

  versioning = {
    enabled = var.versioning
  }
}