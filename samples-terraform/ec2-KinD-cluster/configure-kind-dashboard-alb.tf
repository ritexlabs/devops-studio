
// Create Target Group For KinD Dashboard
resource "aws_lb_target_group" "tg-kinddsb" {
  depends_on  = [null_resource.wait_for_instance_status]
  name        = "${var.resource_prefix}-kinddsb-tg"
  port        = 32000
  protocol    = "HTTPS"
  vpc_id      = data.aws_vpc.selected.id

  health_check {
    path = "/"
    protocol = "HTTPS"
    port = "32000"
    interval = 30
    timeout = 10
    healthy_threshold = 5
    unhealthy_threshold = 5
    matcher = "200,302,307"
  }
}

// Attach KinD Kubernetes Dashboard Target Group 
 resource "aws_lb_target_group_attachment" "tg_attachment_kinddsb" {
  depends_on       = [aws_lb_target_group.tg-kinddsb]
  target_group_arn = aws_lb_target_group.tg-kinddsb.arn
  target_id        = module.ec2_instance.id
  port             = 32000
 }

// Create Listner Rule For KinD Kubernetes Dashboard
resource "aws_lb_listener_rule" "rule_kinddsb" {
  depends_on    = [aws_lb_target_group.tg-kinddsb]
  listener_arn  = data.aws_lb_listener.selected-alb-listner.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-kinddsb.arn
  }
  condition {
    host_header{
      values = [local.kinddashboard_dns_name]
    }
  }
}

// Record creation of All-In-One Instance For NginX
resource "aws_route53_record" "record_cname_kinddsb" {  
  zone_id = var.hosted_zoneid
  name    = local.kinddashboard_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [data.aws_lb.selected-alb.dns_name]
}
