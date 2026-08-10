terraform {
  required_version = ">= 1.11.0"

  backend "s3" {
    bucket       = "project-bedrock-tfstate-alt-soe-tin-025-0120"
    key          = "project-bedrock/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}


