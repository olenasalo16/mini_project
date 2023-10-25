resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg-"
  vpc_id      = var.vpc_id
  description = "mini-project-alb-sg"

  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {

    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb_name" {
  name                       = var.alb_name
  internal                   = false
  load_balancer_type         = var.alb_type
  security_groups            = [aws_security_group.alb_sg.id]
  enable_deletion_protection = false
  subnets                    = [var.alb_subnet_1, var.alb_subnet_2]
}
###
# Target groups

resource "aws_lb_target_group" "frontend_target_group" {
  name        = var.alb_be_tg_name
  port        = 80
  protocol    = "HTTP"
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = "/"
    unhealthy_threshold = "2"
  }

  depends_on = [aws_lb.alb_name]
}

resource "aws_lb_target_group" "backend_target_group" {
  name        = var.alb_fe_tg_name
  port        = 443
  protocol    = var.protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTPS"
    matcher             = "200"
    timeout             = "5"
    path                = "/"
    unhealthy_threshold = "2"
  }

  depends_on = [aws_lb.alb_name]
}

##
# Load Balancer Listeners

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = [aws_lb.alb_name.arn]
  port              = 80
  protocol          = "HTTP"
  # ssl_policy        = var.ssl_policy
  # certificate_arn   = var.cert_arn

  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https_listener" {
  load_balancer_arn = [aws_lb.alb_name.arn]
  port              = 443
  protocol          = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-2016-08"

  certificate_arn = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }
}

##
# Listener rules

resource "aws_lb_listener_rule" "frontend_rule" {
  listener_arn = aws_alb_listener.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }

  condition {
    host_header {
      values = ["reviews.massaee.click"]
    }
  }
}

resource "aws_lb_listener_rule" "backend_rule" {
  listener_arn = aws_alb_listener.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_target_group.arn
  }

  condition {
    host_header {
      values = ["reviews-api.massaee.click"]
    }
  }
}

## 
# Listener certificate

resource "aws_acm_certificate_validation" "frontend_rule_tls_cert_arn" {
  certificate_arn = var.cert_arn
}

resource "aws_lb_listener_certificate" "frontend_rule_tls_certificate" {
  listener_arn    = aws_alb_listener.https_listener.arn
  certificate_arn = aws_acm_certificate_validation.frontend_rule_tls_cert_arn.certificate_arn
}

resource "aws_acm_certificate_validation" "backend_rule_tls_cert_arn" {
  certificate_arn = var.cert_arn
}

resource "aws_lb_listener_certificate" "backend_rule_tls_certificate" {
  listener_arn    = aws_alb_listener.https_listener.arn
  certificate_arn = aws_acm_certificate_validation.backend_rule_tls_cert_arn.certificate_arn
}

##
# Create the Route 53 health check

resource "aws_route53_health_check" "failover_health_check" {
  fqdn              = "reviews.massaee.click"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = var.failover_bucket_name
  }
}


resource "aws_route53_record" "frontend_record" {
  zone_id = var.zone_id
  name    = var.frontend_record
  # ttl     = 300
  type = "CNAME"

  alias {
    name                   = [aws_alb.alb_name.dns_name]
    zone_id                = var.zone_id
    evaluate_target_health = true
  }
  # records = [aws_lb.my_alb.dns_name]

}

resource "aws_route53_record" "failover_record" {
  zone_id = var.zone_id         #  Route 53 hosted zone ID
  name    = var.frontend_record #  domain
  type    = "CNAME"

  alias {
    name                   = [aws_s3_object.maintenance_object.dns_name] # Redirect to the S3 bucket hosting the maintenance page
    zone_id                = var.zone_id                                 #  Route 53 hosted zone ID
    evaluate_target_health = false                                       # Disable health check evaluation
  }

  failover_routing_policy {
    type = "SECONDARY"
  }
}
resource "aws_route53_record" "backend_record" {
  zone_id = var.zone_id        #  Route 53 hosted zone ID
  name    = var.backend_record # subdomain
  type    = "CNAME"

  alias {
    name                   = [aws_alb.alb_name.dns_name] # DNS name of ALB
    zone_id                = var.zone_id                 #  hosted zone ID
    evaluate_target_health = true
  }
}
# resource "aws_route53_record" "backend_record" {
#   zone_id = var.zone_id
#   name    = var.backend_record
#   ttl     = 300
#   type    = "CNAME"
#   records = [aws_lb.my_alb.dns_name]
# }

# resource "aws_route53_record" "failover_record" {
#   zone_id = var.zone_id
#   name    = var.failover_record
#   type    = "CNAME"

#   failover_routing_policy {
#     type = "PRIMARY"
#   }
#   set_identifier = "primary"
#   # records        = [aws_lb.my_alb.dns_name]
#   alias {
#     name                   = aws_lb.my_alb.dns_name
#     zone_id                = aws_lb.my_alb.zone_id
#     evaluate_target_health = true
#   }
# }



