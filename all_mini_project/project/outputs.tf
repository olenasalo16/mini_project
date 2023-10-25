output "vpc_id" {
  value = module.app_vpc.vpc_id
}
output "public_subnet1_id" {
  value = module.app_vpc.public_subnet1_id
}
output "public_subnet2_id" {
  value = module.app_vpc.public_subnet2_id
}
output "private_subnet1_id" {
  value = module.app_vpc.private_subnet1_id
}
output "private_subnet2_id" {
  value = module.app_vpc.private_subnet2_id
}
output "frontend_tg_arn" {
  value = module.alb.frontend_tg_arn
}
output "backend_tg_arn" {
  value = module.alb.backend_tg_arn
}

# output "backend_launch_template_id" {
#   description = "Launch Template ID"
#   value       = module.lt.backend_launch_template_id

output "s3_bucket_url" {
  value = module.s3_module.s3_bucket_url
}
# output "alb_sg" {
#   value = module.app_vpc.
# }
output "alb_sg" {
  value = [module.alb.alb_sg.ids]
}
output "bastion_sg" {
  value = [module.bastion_host.bastion_sg.id]
}
output "maintenance_object_dns_name" {
  value = [module.s3_module.maintenance_object.dns_name]
}
