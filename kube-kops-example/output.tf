output "bucket_name" {
  value = module.kops-k8s.bucket_name
}
output "master_nodes" {
  value = module.kops-k8s.master_nodes
}
output "worker_nodes" {
  value = module.kops-k8s.worker_nodes
}
output "cluster_name" {
  value = module.kops-k8s.cluster_name
}

