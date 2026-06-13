
// Create Target Group For NginX
resource "aws_lb_target_group" "tg-nginx" {
  depends_on  = [null_resource.wait_for_instance_status]
  name        = "${var.resource_prefix}-nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.selected.id

  health_check {
    path = "/"
    port = "80"
    interval = 30
    timeout = 10
    healthy_threshold = 5
    unhealthy_threshold = 5
    matcher = "200,302,307"
  }
}

// Attach NginX Target Group 
 resource "aws_lb_target_group_attachment" "tg_attachment_nginx" {
  depends_on       = [aws_lb_target_group.tg-nginx]
  target_group_arn = aws_lb_target_group.tg-nginx.arn
  target_id        = module.ec2_instance.id
  port             = 80
 }

// Create Listner Rule For NginX
resource "aws_lb_listener_rule" "rule_nginx" {
  depends_on    = [aws_lb_target_group.tg-nginx]
  listener_arn  = data.aws_lb_listener.selected-alb-listner.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-nginx.arn
  }
  condition {
    host_header{
      values = [local.nginx_dns_name]
    }
  }
}

// Record creation of All-In-One Instance For NginX
resource "aws_route53_record" "record_cname_nginx" {  
  zone_id = var.hosted_zoneid
  name    = local.nginx_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [data.aws_lb.selected-alb.dns_name]
}
