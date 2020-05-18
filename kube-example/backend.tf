# delete this file if you want use local state (NOT RECOMENDET)
terraform {
  backend "s3" {
    bucket         = "your_bucket_name"
    key            = "k8s/terraform.tfstate"
    region         = "your_region"
    dynamodb_table = "your_dynamo_db_table_name"
  }
}