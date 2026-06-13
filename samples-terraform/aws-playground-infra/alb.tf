// Application Load Balancer configuration

data "aws_acm_certificate" "eis_certificate" {
  domain = var.domain_name
  statuses = ["ISSUED"]      
  types = ["AMAZON_ISSUED"]  
  most_recent = true         
}

resource "aws_lb" "playground-alb" {
  depends_on         = [module.vpc]
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.eis_allow_sg.id]
  subnets            = [module.vpc.public_subnets[0],module.vpc.public_subnets[1]]

  tags = {
    Environment     = var.tag_envname
    Name            = local.alb_name
  }
}

# Keep a fixed response on the listener; traffic is routed through the target group
resource "aws_lb_listener" "https_forward" {
  depends_on        = [aws_lb.playground-alb]
  load_balancer_arn = aws_lb.playground-alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.eis_certificate.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service Unavailable"
      status_code  = "503"
    }
  }
}
