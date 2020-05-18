output "elb_fqdn" {
  value = module.k8s.elb_api_fqdn
}

output "kubeconfig" {
  value = module.k8s.kubeconfig
}

output "cluster_name" {
  value = module.k8s.cluster_name
}

output "bastion_public_ip" {
  value = module.k8s.bastion_public_ip
}

output "cluster_nodes" {
  value = module.k8s.cluster_nodes
}