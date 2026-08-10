############################################
# Database Security Group
############################################

resource "aws_security_group" "database" {
  name        = "project-bedrock-database-sg"
  description = "Security group for Project Bedrock RDS databases"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "project-bedrock-database-sg"
    Project = "tinyuka-2025-capstone"
  }
}

############################################
# MySQL Access from EKS
############################################

resource "aws_vpc_security_group_ingress_rule" "mysql_from_eks" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = var.eks_security_group_id

  from_port = 3306
  to_port   = 3306
  ip_protocol = "tcp"

  description = "Allow MySQL traffic from EKS"
}

############################################
# PostgreSQL Access from EKS
############################################

resource "aws_vpc_security_group_ingress_rule" "postgres_from_eks" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = var.eks_security_group_id

  from_port = 5432
  to_port   = 5432
  ip_protocol = "tcp"

  description = "Allow PostgreSQL traffic from EKS"
}

############################################
# Database Egress
############################################

resource "aws_vpc_security_group_egress_rule" "database_all" {
  security_group_id = aws_security_group.database.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow outbound database traffic"
}

############################################
# RDS Subnet Group
############################################

resource "aws_db_subnet_group" "this" {
  name = "project-bedrock-db-subnet-group"

  subnet_ids = var.private_subnet_ids

  tags = {
    Name    = "project-bedrock-db-subnet-group"
    Project = "tinyuka-2025-capstone"
  }
}

############################################
# MySQL Credentials
############################################

resource "random_password" "mysql" {
  length  = 24

  special = true

  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "mysql" {
  name = "project-bedrock/mysql"

  description = "Credentials for Project Bedrock RDS MySQL"

  tags = {
    Name    = "project-bedrock-mysql-secret"
    Project = "tinyuka-2025-capstone"
  }
}

resource "aws_secretsmanager_secret_version" "mysql" {
  secret_id = aws_secretsmanager_secret.mysql.id

  secret_string = jsonencode({
    username = var.mysql_username
    password = random_password.mysql.result
    engine   = "mysql"
  })
}

############################################
# PostgreSQL Credentials
############################################

resource "random_password" "postgres" {
  length = 24

  special = true

  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "postgres" {
  name = "project-bedrock/postgres"

  description = "Credentials for Project Bedrock RDS PostgreSQL"

  tags = {
    Name    = "project-bedrock-postgres-secret"
    Project = "tinyuka-2025-capstone"
  }
}

resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id = aws_secretsmanager_secret.postgres.id

  secret_string = jsonencode({
    username = var.postgres_username
    password = random_password.postgres.result
    engine   = "postgres"
  })
}

############################################
# RDS MySQL - Catalog Service
############################################

resource "aws_db_instance" "mysql" {
  identifier = "project-bedrock-catalog"

  engine = "mysql"

  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "catalog"
  username = var.mysql_username
  password = random_password.mysql.result

  port = 3306

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    aws_security_group.database.id
  ]

  publicly_accessible = false

  multi_az = false

  backup_retention_period = 7

  backup_window = "03:00-04:00"

  maintenance_window = "sun:04:00-sun:05:00"

  storage_encrypted = true

  deletion_protection = false

  skip_final_snapshot = true

  auto_minor_version_upgrade = true

  apply_immediately = true

  tags = {
    Name    = "project-bedrock-catalog-mysql"
    Project = "tinyuka-2025-capstone"
  }

  depends_on = [
    aws_db_subnet_group.this,
    aws_vpc_security_group_ingress_rule.mysql_from_eks
  ]
}

############################################
# RDS PostgreSQL - Orders Service
############################################

resource "aws_db_instance" "postgres" {
  identifier = "project-bedrock-orders"

  engine = "postgres"

  engine_version = "16"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "orders"
  username = var.postgres_username
  password = random_password.postgres.result

  port = 5432

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    aws_security_group.database.id
  ]

  publicly_accessible = false

  multi_az = false

  backup_retention_period = 7

  backup_window = "04:00-05:00"

  maintenance_window = "sun:05:00-sun:06:00"

  storage_encrypted = true

  deletion_protection = false

  skip_final_snapshot = true

  auto_minor_version_upgrade = true

  apply_immediately = true

  tags = {
    Name    = "project-bedrock-orders-postgres"
    Project = "tinyuka-2025-capstone"
  }

  depends_on = [
    aws_db_subnet_group.this,
    aws_vpc_security_group_ingress_rule.postgres_from_eks
  ]
}
