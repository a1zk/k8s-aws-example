# delete this file if you want use local state (NOT RECOMENDET)
terraform {
  backend "s3" {
    bucket         = "your_bucket_name"
    key            = "k8s-kops/terraform.tfstate"
    region         = "your_region"
    dynamodb_table = "your_dynomodb_table_name"
  }
}