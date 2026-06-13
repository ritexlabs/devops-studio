
// Create Target Group For Grafana
resource "aws_lb_target_group" "tg-grafana" {
  depends_on  = [null_resource.wait_for_instance_status]
  name        = "${var.resource_prefix}-grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.selected.id

  health_check {
    path = "/"
    port = "3000"
    interval = 30
    timeout = 10
    healthy_threshold = 5
    unhealthy_threshold = 5
    matcher = "200,302,307"
  }
}

// Attach Grafana Target Group 
 resource "aws_lb_target_group_attachment" "tg_attachment_grafana" {
  depends_on       = [aws_lb_target_group.tg-grafana]
  target_group_arn = aws_lb_target_group.tg-grafana.arn
  target_id        = module.ec2_instance.id
  port             = 3000
 }

// Create Listner Rule For grafana
resource "aws_lb_listener_rule" "rule_grafana" {
  depends_on    = [aws_lb_target_group.tg-grafana]
  listener_arn  = data.aws_lb_listener.selected-alb-listner.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-grafana.arn
  }
  condition {
    host_header{
      values = [local.grafana_dns_name]
    }
  }
}

// Record creation of All-In-One Instance For NginX
resource "aws_route53_record" "record_cname_grafana" {  
  zone_id = var.hosted_zoneid
  name    = local.grafana_dns_name
  type    = "CNAME"
  ttl     = 300
  records = [data.aws_lb.selected-alb.dns_name]
}
