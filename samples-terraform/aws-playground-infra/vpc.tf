provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals { 
  vpc_name          = "${var.resource_prefix}-vpc"
  sg_name           = "${var.resource_prefix}-sg"
  alb_name          = "${var.resource_prefix}-alb"

  pvt_subnet_name   = "${var.resource_prefix}-private-subnet"
  pub_subnet_name   = "${var.resource_prefix}-public-subnet"

  igw_name          = "${var.resource_prefix}-igw"

  rt_public_name    = "${var.resource_prefix}-rt-public"
  rt_private_name   = "${var.resource_prefix}-rt-private"
  rt_default_name = "${var.resource_prefix}-rt-default"

  nat_name          = "${var.resource_prefix}-nat"
  nat_eip_name      = "${var.resource_prefix}-nat-eip"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name                 = local.vpc_name
  cidr                 = "10.0.0.0/16"
  azs                  = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets      = ["10.0.0.0/18","10.0.64.0/18"]
  public_subnets       = ["10.0.128.0/18","10.0.192.0/18"]
  
  enable_nat_gateway   = true
  single_nat_gateway   = true     # Ensures only one NAT GW is created
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Add subnet-specific tags in addition to Name
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    Name = local.pub_subnet_name
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    Name = local.pvt_subnet_name
  }

  # Internet Gateway tags
  # create_igw = true
  igw_tags = {
    Name = local.igw_name
  }

  # Route table tags
  public_route_table_tags = {
    Name = local.rt_public_name
  }
  private_route_table_tags = {
    Name = local.rt_private_name
  }

  # Default route table tags
  manage_default_route_table = true
  default_route_table_tags = {
    Name = local.rt_default_name
  }

  # NAT gateway and Elastic IP tags
  nat_gateway_tags = {
    Name = local.nat_name
  }
  nat_eip_tags = {
    Name = local.nat_eip_name
  }

  tags = {
    Environment = var.tag_envname
    Name        = local.vpc_name
  }
}

# Security group for inbound access
resource "aws_security_group" "eis_allow_sg" {
  name        = local.sg_name
  description = "Security group to allow network access"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = [
      module.vpc.vpc_cidr_block,
      "${module.vpc.nat_public_ips[0]}/32"     # Whitelist the VPC NAT gateway
    ]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Description     = "Allow Network Access"
    Name            = local.sg_name
    Environment     = var.tag_envname
  } 
}
