variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

# Networking Informations
variable "vpc_name" {
  description = "Existing VPC Name"
  type        = string
}

variable "sg_name" {
  description = "Existing Security Group Name"
  type        = string
}

variable "alb_name" {
  description = "Existing ALB Name"
  type        = string
}

variable "key_pair_name" {
  description = "SSH Key pair attached with the instance"
  type        = string  
}

variable "hosted_zoneid" {
  description = "Hosted Zone ID"
  type        = string  
}

# Environment Tag
variable "tag_envname" {
  description = "Environment Name"
  type        = string
}

# Domian Name Information
variable "domain_name" {
  description = "Domain Name"
  type        = string
}

# Deployment Information

variable "resource_prefix" {
  description = "Resource Name Prefix"
  type        = string
}

variable "ec2_source_ami" {
  description = "EC2 Source AMI"
  type        = string
}
