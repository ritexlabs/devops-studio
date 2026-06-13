
provider "aws" {  
  region = var.aws_region 
}

# Fetch VPC by its Name tag
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Get Public Subnets in that VPC
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

# Get Security Group by Name
data "aws_security_group" "selected" {
  filter {
    name   = "group-name"
    values = [var.sg_name]
  }

  # Optional: If you want to restrict by VPC
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_lb" "selected-alb" {
  name = var.alb_name
}

data "aws_lb_listener" "selected-alb-listner" {
  load_balancer_arn = data.aws_lb.selected-alb.arn
  port              = 443
}

locals {  
  ec2_instance_name       = "${var.resource_prefix}-ec2-KinD-cluster"
  instance_type           = "t2.medium"
  kinddashboard_dns_name  = "${var.resource_prefix}-kind-dashboard.${var.domain_name}"
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.8.0"

  name                   = local.ec2_instance_name
  ami                    = var.ec2_source_ami
  instance_type          = local.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  subnet_id              = data.aws_subnets.public.ids[0]
  monitoring             = true

  associate_public_ip_address = true 

  root_block_device = [{
    volume_size = 80
    volume_type = "gp3"
  }]

  tags = {
    Environment     = var.tag_envname
    Name            = local.ec2_instance_name
  }
}

resource "null_resource" "wait_for_instance_status" {
  depends_on = [module.ec2_instance]

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${module.ec2_instance.id} --region ${var.aws_region}"
  }
}

