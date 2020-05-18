#var Example
cluster_name            = "k8s-example"
allowed_ssh_cidr_blocks = ["your_public_ip or 0.0.0.0/0"]
num_workers             = 2
worker_instance_type    = "t2.small"
master_instance_type    = "t2.medium"
bastion_num             = 1 