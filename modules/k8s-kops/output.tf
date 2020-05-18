output "bucket_name" {
  value = module.s3_state.bucket_name
}

output "master_nodes" {
  value = var.master_num
}

output "worker_nodes" {
  value = var.node_num
}

output "cluster_name" {
  value = var.dns_name
}


