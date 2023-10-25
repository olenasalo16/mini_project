#Creating Autoscaling group

# resource "aws_autoscaling_group" "asg" {
#   name                = "Autoscaling"
#   capacity_rebalance  = true
#   desired_capacity    = var.desired_capacity
#   max_size            = var.max_size
#   min_size            = var.min_size
#   vpc_zone_identifier = [var.subnet_ids]
#   target_group_arns   = [var.target_group_arns]
#   # Mixed
#   mixed_instances_policy {
#     launch_template {
#       launch_template_specification {
#         launch_template_id = var.frontend_launch_template
#       }
#       override {
#         instance_type = "t2.micro"
#       }

#       override {
#         instance_type = "t3.micro"
#         launch_template_specification {
#           launch_template_id = var.backend_launch_template

#         }
#       }x
#     }
#   }
# }

resource "aws_launch_template" "launch_template" {
  name_prefix            = var.lt_name_prefix
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.asg_instance_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name       = var.name
  depends_on = [aws_launch_template.launch_template]

  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 1
  vpc_zone_identifier       = [var.subnet_ids]
  target_group_arns         = var.target_group_arns
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}

# Autoscaling Policy

resource "aws_autoscaling_policy" "CPU_scaling_policies" {
  name                      = "CPU_scaling_policies"
  autoscaling_group_name    = aws_autoscaling_group.asg.name
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 180

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60
  }
}

resource "aws_security_group" "asg_instance_sg" {
  name = "learn-asg-terramino-instance"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_ids]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id
}
