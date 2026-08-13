variable "vpc_id" {
  description = "VPC ID for the Redis ElastiCache resources"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Redis"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "Security group ID allowed to access Redis"
  type        = string
}

variable "cache_name" {
  description = "ElastiCache replication group name"
  type        = string
  default     = "project-bedrock-redis"
}

variable "node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t3.micro"
}
