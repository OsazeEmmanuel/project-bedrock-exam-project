############################################
# Redis Security Group
############################################

resource "aws_security_group" "redis" {
  name        = "project-bedrock-redis-sg"
  description = "Security group for Project Bedrock Redis"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "project-bedrock-redis-sg"
    Project = "tinyuka-2025-capstone"
  }
}

############################################
# Redis Ingress from EKS
############################################

resource "aws_vpc_security_group_ingress_rule" "redis_from_eks" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = var.eks_security_group_id

  from_port   = 6379
  to_port     = 6379
  ip_protocol = "tcp"

  description = "Allow Redis traffic from EKS"
}

############################################
# Redis Egress
############################################

resource "aws_vpc_security_group_egress_rule" "redis_all" {
  security_group_id = aws_security_group.redis.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow outbound Redis traffic"
}

############################################
# ElastiCache Subnet Group
############################################

resource "aws_elasticache_subnet_group" "redis" {
  name = "project-bedrock-redis-subnet-group"

  subnet_ids = var.private_subnet_ids

  tags = {
    Name    = "project-bedrock-redis-subnet-group"
    Project = "tinyuka-2025-capstone"
  }
}

############################################
# Redis Replication Group
############################################

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = var.cache_name

  description = "Redis cache for Project Bedrock"

  engine         = "redis"
  engine_version = "7.1"

  node_type = var.node_type

  num_cache_clusters = 1

  port = 6379

  subnet_group_name = aws_elasticache_subnet_group.redis.name

  security_group_ids = [
    aws_security_group.redis.id
  ]

  automatic_failover_enabled = false

  multi_az_enabled = false

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  snapshot_retention_limit = 1

  apply_immediately = true

  tags = {
    Name    = "project-bedrock-redis"
    Project = "tinyuka-2025-capstone"
  }

  depends_on = [
    aws_vpc_security_group_ingress_rule.redis_from_eks
  ]
}
