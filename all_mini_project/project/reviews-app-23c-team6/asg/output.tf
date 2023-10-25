output "autoscaling_group_id" {
  description = "Autoscaling Group ID"
  value       = aws_autoscaling_group.asg.id
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.asg.name
}

output "asg_instance_sg_id" {
  value = [aws_security_group.asg_instance_sg.id]
}

output "asg_id" {
  value = aws_autoscaling_group.asg.id
}

output "launch_template_id" {
  value = aws_launch_template.launch_template.id
}
# output "alb_sg_ids" {
#   value = [aws_security_group.alb_sg.ids]
# }
