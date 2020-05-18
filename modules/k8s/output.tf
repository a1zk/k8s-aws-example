output "elb_api_id" {
  value = aws_elb.aws-elb-api.id
}

output "elb_api_fqdn" {
  value = aws_elb.aws-elb-api.dns_name
}

output "kubeconfig" {
  value       = path.cwd
  description = "Location of the kubeconfig file for the created cluster on the local machine."
}

output "cluster_name" {
  value       = local.cluster_name
  description = "Name of the created cluster. This name is used as the value of the \"kubeadm:cluster\" tag assigned to all created AWS resources."
}

output "bastion_public_ip" {
  value = aws_eip.bastion.public_ip
}

output "cluster_nodes" {
  value = [
    for i in concat([aws_instance.master], aws_instance.workers, ) : {
      name       = i.tags["kubeadm:node"]
      subnet_id  = i.subnet_id
      private_ip = i.private_ip
    }
  ]
  description = "Name, private IP address, and subnet ID of all nodes of the created cluster."
}


