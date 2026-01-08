terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Networking Module (VPC, Subnet, IGW, Route Table, Security Group)
module "networking" {
  source = "./modules/networking"

  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
  availability_zone = var.availability_zone
  allowed_ssh_cidr  = var.allowed_ssh_cidr
  project_name      = var.project_name
}

# Compute Module (EC2 Instance)
module "compute" {
  source = "./modules/compute"

  ami_id             = var.ami_id
  instance_type      = var.instance_type
  subnet_id          = module.networking.subnet_id
  security_group_ids = [module.networking.security_group_id]
  key_name           = var.key_name
  project_name       = var.project_name
}
