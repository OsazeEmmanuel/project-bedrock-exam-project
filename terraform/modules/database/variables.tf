
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "EKS security group allowed to access RDS"
  type        = string
}

variable "mysql_username" {
  description = "MySQL master username"
  type        = string
  default     = "catalogadmin"
}

variable "postgres_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "ordersadmin"
}

output "mysql_endpoint" {
  description = "RDS MySQL endpoint for the Catalog service"
  value       = aws_db_instance.mysql.address
}

output "mysql_port" {
  description = "RDS MySQL port"
  value       = aws_db_instance.mysql.port
}

output "postgres_endpoint" {
  description = "RDS PostgreSQL endpoint for the Orders service"
  value       = aws_db_instance.postgres.address
}

output "postgres_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.postgres.port
}

output "mysql_secret_arn" {
  description = "Secrets Manager ARN containing MySQL credentials"
  value       = aws_secretsmanager_secret.mysql.arn
}

output "postgres_secret_arn" {
  description = "Secrets Manager ARN containing PostgreSQL credentials"
  value       = aws_secretsmanager_secret.postgres.arn
}

output "database_security_group_id" {
  description = "Security group ID for the RDS databases"
  value       = aws_security_group.database.id
}
