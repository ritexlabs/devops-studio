aws_region              = "us-east-2"
vpc_name                = "playground-vpc"
sg_name                 = "playground-sg"
alb_name                = "playground-alb"
hosted_zoneid           = "XXXXXXXXXXXXXXXXX"

resource_prefix         = "grafana"
ec2_source_ami          = "ami-0f5fcdfbd140e4ab7"     // Ubuntu System
key_pair_name           = "xxxxxxxxxxx"
domain_name             = "example.com"
tag_envname             = "grafana"