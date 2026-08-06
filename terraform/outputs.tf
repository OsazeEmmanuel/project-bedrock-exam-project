output "region" {
  value = var.aws_region
}

output "vpc_id" {
  value = module.networking.vpc_id
}
