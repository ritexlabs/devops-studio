aws_region              = "us-east-2"
vpc_name                = "playground-vpc"
sg_name                 = "playground-sg"
alb_name                = "playground-alb"
hosted_zoneid           = "xxxxxxxxxxxx"

resource_prefix         = "kind"
ec2_source_ami          = "ami-0f5fcdfbd140e4ab7"     // Ubuntu System
key_pair_name           = "xxxxxxxxxxxxxxxx"
domain_name             = "example.com"
tag_envname             = "kind"