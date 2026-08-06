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
