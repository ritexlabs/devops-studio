output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "key_pair_name" {
  description = "SSH Key Pair Name"
  value       = var.key_pair_name
}

output "ec2_instance_name" {
  description = "EC2 Instance Name"
  value       = local.ec2_instance_name
}

output "ec2_vpc_id" {
  description = "VPC ID"
  value       = data.aws_vpc.selected.id
}

output "ec2_public_subnet_ids" {
  description = "Public subnet ids"
  value       = data.aws_subnets.public.ids
}

output "ec2_security_groups" {
  description = "Public subnet ids"
  value       = data.aws_security_group.selected.id
}

output "nginx_dns_name" {
  description = "NginX DNS Name"
  value       = "https://${local.nginx_dns_name}"
}

output "grafana_dns_name" {
  description = "Grafana DNS Name"
  value       = "https://${local.grafana_dns_name}"
}