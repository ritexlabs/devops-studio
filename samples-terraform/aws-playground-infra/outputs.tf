output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "aws_vpc_name" {
  description = "AWS created VPC name"
  value       = module.vpc.name
}

output "aws_vpc_cidr_block" {
  description = "AWS created VPC cidr block"
  value       = module.vpc.vpc_cidr_block
}

output "loadbalancer_arn" {
  description = "Application Load Balancer ARN"
  value       = aws_lb.playground-alb.arn
}

output "loadbalancer_dnsname" {
  description = "Application Load Balancer DNS Name"
  value       = aws_lb.playground-alb.dns_name
}

output "nat_gateway_public_ip" {
  description = "Public IPs of all NAT Gateways"
  value       = module.vpc.nat_public_ips[0]
}
