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
