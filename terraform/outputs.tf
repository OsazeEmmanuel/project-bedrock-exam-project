output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "Project VPC ID"
  value       = module.networking.vpc_id
}

output "assets_bucket_name" {
  description = "Name of the Bedrock assets S3 bucket"
  value       = module.storage.assets_bucket_name
}
