output "frontend_tg_arn" {
  value = aws_lb_target_group.frontend_target_group.arn
}
output "backend_tg_arn" {
  value = aws_lb_target_group.backend_target_group.arn
}
output "alb_sg" {
  value = aws_security_group.alb_sg.id
}
output "aws_alb_arn" {
  value = [aws_lb.alb_name.arn]
}

output "name" {
  value = [aws_alb_listener.https_listener.arn]
}

output "alb_dns_name" {
  value = aws_lb.alb_name.dns_name
}

output "aws_acm_certificate_validation" {
  value = aws_acm_certificate_validation.frontend_rule_tls_cert_arn.certificate_arn
}

output "aws_acm_backend_certificate_validation" {
  value = aws_acm_certificate_validation.backend_rule_tls_cert_arn.certificate_arn
}

output "maintenance_object_dns_name" {
  value = [aws_s3_object.maintenance_object.dns_name]
}
