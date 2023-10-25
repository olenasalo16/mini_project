variable "lt_name_prefix" {}

variable "instance_type" {}

variable "ami_id" {}

variable "desired_capacity" {}

variable "max_size" {}

variable "min_size" {}

variable "subnet_ids" {}

variable "launch_template" {}

variable "target_group_arns" {
  type = list(string)
}
variable "vpc_id" {}
variable "name" {
  type = string
}
variable "alb_sg_ids" {}
