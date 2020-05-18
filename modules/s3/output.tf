output "bucket_name" {
  value = module.s3-bucket.this_s3_bucket_id
}

output "bucket_domain" {
  value = module.s3-bucket.this_s3_bucket_bucket_domain_name
}

output "bucket_arn" {
  value = module.s3-bucket.this_s3_bucket_arn
}


