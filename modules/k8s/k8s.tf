
resource "random_pet" "cluster_name" {}

locals {
  cluster_name = var.cluster_name != null ? var.cluster_name : random_pet.cluster_name.id
  tags         = merge(var.tags, { "kubeadm:cluster" = local.cluster_name })
}
# Creating ELB SG

resource "aws_security_group" "aws-elb" {
  name   = "kubernetes-${var.cluster_name}-securitygroup-elb"
  vpc_id = var.vpc_id

  tags = merge(local.tags, { "Name" = "${local.cluster_name}-elb" })
}

resource "aws_security_group_rule" "aws-allow-api-access" {
  type              = "ingress"
  from_port         = var.elb_api_port
  to_port           = var.k8s_secure_api_port
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-elb.id
}
resource "aws_security_group_rule" "allow-check" {
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-elb.id
}
resource "aws_security_group_rule" "aws-allow-api-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws-elb.id
}
# Create a new ELB for K8S API
resource "aws_elb" "aws-elb-api" {
  name = "kubernetes-elb-${var.cluster_name}"
  #availability_zones = var.aws_avail_zones
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.aws-elb.id]

  listener {
    instance_port     = var.k8s_secure_api_port
    instance_protocol = "tcp"
    lb_port           = var.elb_api_port
    lb_protocol       = "tcp"
  }
  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 8000
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:${var.k8s_secure_api_port}"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = merge(local.tags, { "Name" = "${local.cluster_name}-sg-elb-api" })
}

# Performs 'ImportKeyPair' API operation (not 'CreateKeyPair')
resource "aws_key_pair" "main" {
  key_name_prefix = "${local.cluster_name}-"
  public_key      = file(var.public_key_file)
  tags            = local.tags
}

#SG for bastion host 

resource "aws_security_group" "ingress_ssh" {
  name        = "${local.cluster_name}-ingress-ssh"
  description = "Allow incoming SSH traffic (TCP/22) from outside the cluster"
  vpc_id      = var.vpc_id
  tags        = merge(local.tags, { "Name" = "${local.cluster_name}-sg-ssh-allow" })
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# EIP for bastion node
resource "aws_eip" "bastion" {
  vpc  = true
  tags = local.tags
}

resource "aws_eip_association" "bastion" {
  count         = var.bastion_num
  allocation_id = aws_eip.bastion.id
  instance_id   = element(aws_instance.bastion-server.*.id, count.index)
}

# Creating bastion Host
resource "aws_instance" "bastion-server" {
  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = var.bastion_size
  count                       = var.bastion_num
  associate_public_ip_address = true
  availability_zone           = element(slice(var.aws_avail_zones, 1, length(var.aws_avail_zones)), count.index)
  subnet_id                   = element(slice(var.public_subnet_ids, 1, length(var.public_subnet_ids)), count.index)

  vpc_security_group_ids = [aws_security_group.ingress_ssh.id]

  key_name = aws_key_pair.main.key_name

  tags = merge(local.tags, map(
    "Role", "bastion-${var.cluster_name}-${count.index}",
    "Name", "bastion-${var.cluster_name}-${count.index}",
  ))
}

## >>>> K8s part

# The AWS provider removes the default "allow all "egress rule from all security
# groups, so it has to be defined explicitly.

resource "aws_security_group" "egress" {
  name        = "${local.cluster_name}-egress"
  description = "Allow all outgoing traffic to everywhere"
  vpc_id      = var.vpc_id
  tags        = merge(local.tags, { "Name" = "${local.cluster_name}-sg-egress" })
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress_internal" {
  name        = "${local.cluster_name}-ingress-internal"
  description = "Allow all incoming traffic from nodes and Pods in the cluster"
  vpc_id      = var.vpc_id
  tags        = merge(local.tags, { "Name" = "${local.cluster_name}-sg-ingress_internal" })
  ingress {
    protocol        = -1
    from_port       = 0
    to_port         = 0
    self            = true
    security_groups = [aws_security_group.aws-elb.id]
    description     = "Allow incoming traffic from cluster nodes"

  }
  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.pod_network_cidr_block != null ? [var.pod_network_cidr_block] : null
    description = "Allow incoming traffic from the Pods of the cluster"
  }
}

# Generate bootstrap token
# See https://kubernetes.io/docs/reference/access-authn-authz/bootstrap-tokens/
resource "random_string" "token_id" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token_secret" {
  length  = 16
  special = false
  upper   = false
}

locals {
  token = "${random_string.token_id.result}.${random_string.token_secret.result}"
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] # AWS account ID of Canonical
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.image_id
  instance_type = var.master_instance_type


  subnet_id = var.private_subnet_id[0]

  key_name = aws_key_pair.main.key_name
  vpc_security_group_ids = [
    aws_security_group.egress.id,
    aws_security_group.ingress_internal.id,
    aws_security_group.ingress_ssh.id
  ]
  tags      = merge(local.tags, { "kubeadm:node" = "master" }, { "Name" = "master" })
  user_data = <<-EOT
  #!/bin/bash
  # Install kubeadm and Docker
  apt-get update
  apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
  deb https://apt.kubernetes.io/ kubernetes-xenial main
  EOF
  add-apt-repository -y ppa:ubuntu-toolchain-r/ppa
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io kubelet kubeadm kubectl python3.7
  update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2 
  systemctl start docker && systemctl enable docker
  # Run kubeadm
  kubeadm init \
    --token "${local.token}" \
    --token-ttl 15m \
    --apiserver-cert-extra-sans "${aws_elb.aws-elb-api.dns_name}" \
  %{if var.pod_network_cidr_block != null~}
    --pod-network-cidr "${var.pod_network_cidr_block}" \
  %{endif~}
    --node-name master
  # Prepare kubeconfig file for download to local machine
  mkdir -p /tmp/check/conf
  cp /etc/kubernetes/admin.conf /tmp/check/conf/admin.conf
  kubectl --kubeconfig /tmp/check/conf/admin.conf config set-cluster kubernetes --server https://${aws_elb.aws-elb-api.dns_name}:6443
  sleep 5
  curl -s https://docs.projectcalico.org/manifests/calico.yaml | sudo kubectl apply -f - --kubeconfig /tmp/check/conf/admin.conf
  # Indicate completion of bootstrapping on this node
  echo "OK" > /tmp/check/done.html && timeout 120s python3 -m http.server --directory /tmp/check
  EOT
}
resource "aws_elb_attachment" "attach_master_nodes" {
  elb      = aws_elb.aws-elb-api.id
  instance = aws_instance.master.id
}


resource "aws_instance" "workers" {
  count         = var.num_workers
  ami           = data.aws_ami.ubuntu.image_id
  instance_type = var.worker_instance_type
  subnet_id     = element(var.private_subnet_id, count.index)
  key_name      = aws_key_pair.main.key_name
  vpc_security_group_ids = [
    aws_security_group.egress.id,
    aws_security_group.ingress_internal.id,
    aws_security_group.ingress_ssh.id
  ]
  tags      = merge(local.tags, { "kubeadm:node" = "worker-${count.index}" }, { "Name" = "worker-${count.index}" })
  user_data = <<-EOT
  #!/bin/bash
  # Install kubeadm and Docker
  apt-get update
  apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
  deb https://apt.kubernetes.io/ kubernetes-xenial main
  EOF
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io kubelet kubeadm kubectl
  systemctl start docker && systemctl enable docker
  # Run kubeadm
  kubeadm join ${aws_instance.master.private_ip}:6443 \
    --token ${local.token} \
    --discovery-token-unsafe-skip-ca-verification \
    --node-name worker-${count.index}
  EOT 

}

# Wait for bootstrap to finish on all nodes

resource "null_resource" "wait_for_bootstrap_to_finish" {


  provisioner "local-exec" {
    command = <<-EOT
    while true; do
      sleep 2
      data=$(curl -s ${aws_elb.aws-elb-api.dns_name}:8000/done.html)
      if [ "$data" != "OK" ]; then
        echo "Wait.."
        continue
      else
        echo "OK"
        break
      fi
    done
    EOT

  }
  triggers = {
    instance_ids = join(",", concat([aws_instance.master.id], aws_instance.workers[*].id))
  }
}

# Download kubeconfig file from master node to local machine

resource "null_resource" "download_kubeconfig_file" {
  provisioner "local-exec" {
    command = <<-EOF
    curl -s ${aws_elb.aws-elb-api.dns_name}:8000/conf/admin.conf -O 
    EOF
  }
  triggers = {
    wait_for_bootstrap_to_finish = null_resource.wait_for_bootstrap_to_finish.id
  }
}