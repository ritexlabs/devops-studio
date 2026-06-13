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

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = module.ec2_instance.public_dns
}

output "kinddashboard_dns_name" {
  description = "KinD Daahboard DNS Name"
  value       = "https://${local.kinddashboard_dns_name}"
}