
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
  ec2_instance_name = "${var.resource_prefix}-ec2-grafana-server"
  instance_type     = "t2.medium"
  nginx_dns_name    = "${var.resource_prefix}-nginx.${var.domain_name}"
  grafana_dns_name  = "${var.resource_prefix}-grafana.${var.domain_name}"
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

  user_data = <<-EOF
    #!/bin/bash
    # Update and install packages
    sudo apt update -y
    sudo apt-get install -y apt-transport-https
    sudo apt-get install -y software-properties-common wget
    sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key

    # Install nginx
    sudo apt install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx

    # Create a simple HTML page
    echo '<!doctype html>
    <html lang="en"><h1>Test Home page!</h1></br>
    <h3>(Instance NginX)</h3>
    </html>' | sudo tee /var/www/html/index.html

    # Installing Grafana Server
    echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
    sudo apt-get update

    # Install the latest OSS release:
    sudo apt-get install grafana -y
    #To start Grafana Server
    sudo /bin/systemctl status grafana-server
    sudo /bin/systemctl enable grafana-server

    # Install Docker and add user to docker group
    sudo apt-get install docker.io -y
    sudo usermod -aG docker ubuntu

    # Optional: flush changes before reboot
    sync

    # Reboot the instance
    sudo reboot
EOF

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
