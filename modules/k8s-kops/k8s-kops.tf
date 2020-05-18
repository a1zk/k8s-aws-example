resource "aws_route53_zone" "domain" {
  name = var.dns_name
  vpc {
    vpc_id = var.vpc_id
  }
}
module "s3_state"{
  source = "../s3"
  bucket_name = var.bucket_name
  region = var.region
}

resource "null_resource" "run_kops"{
    provisioner "local-exec"{
        command = <<-EOT
        kops create cluster \
        --state="s3://${module.s3_state.bucket_name}" \
        --vpc=${var.vpc_id} \
        --master-zones=${var.master_azs} \
        --zones=${var.node_azs} \
        --subnets=${var.subnets} \
        --networking=calico \
        --master-count=${var.master_num} \
        --node-count=${var.node_num} \
        --master-size=${var.master_type} \
        --node-size=${var.node_type} \
        --dns-zone=${var.dns_name} \
        --dns=${var.dns_type} \
        --name=${var.dns_name} \
        --yes
      
      EOT

    }
  depends_on = [
    aws_route53_zone.domain,
    module.s3_state,
  ]
}