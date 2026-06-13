# AWS settings
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "resource_prefix" {
  description = "Resource Prefix"
  type        = string
}

# Domain name settings
variable "domain_name" {
  description = "Domain Name"
  type        = string
}

# Environment Tag
variable "tag_envname" {
  description = "Environment Name"
  type        = string
}
