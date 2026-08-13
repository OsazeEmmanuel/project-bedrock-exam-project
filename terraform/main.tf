module "networking" {
  source = "./modules/networking"

  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name

  availability_zones = var.availability_zones

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = "project-bedrock-cluster"
  cluster_version = "1.34"

  vpc_id = module.networking.vpc_id

  private_subnet_ids = module.networking.private_subnet_ids

  node_instance_type = "t3.medium"

  desired_nodes = 2
  min_nodes     = 2
  max_nodes     = 3
}


module "storage" {
  source = "./modules/storage"
}


module "database" {
  source = "./modules/database"

  vpc_id = module.networking.vpc_id

  private_subnet_ids = module.networking.private_subnet_ids

  eks_security_group_id = module.eks.cluster_security_group_id

  mysql_username    = "catalogadmin"
  postgres_username = "ordersadmin"
}

module "security" {
  source = "./modules/security"

  cluster_name = module.eks.cluster_name

  assets_bucket_arn = module.storage.assets_bucket_arn
  #  assets_bucket_arn  = module.assets.bucket_arn
  dynamodb_table_arn = module.dynamodb.table_arn

  developer_username   = "bedrock-dev-view"
  kubernetes_namespace = "retail-app"
}


module "cache" {
  source = "./modules/cache"

  vpc_id = module.networking.vpc_id

  private_subnet_ids = module.networking.private_subnet_ids

  eks_security_group_id = module.eks.cluster_security_group_id

  cache_name = "project-bedrock-redis"
  node_type  = "cache.t3.micro"
}

module "dynamodb" {
  source = "./modules/dynamodb"

  table_name  = "Items"
  project_tag = "tinyuka-2025-capstone"
}
