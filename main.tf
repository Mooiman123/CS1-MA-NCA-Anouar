terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "network" {
  source = "./network"
  region = var.region
}

module "compute" {
  source        = "./compute"
  vpc_id        = module.network.vpc_id
  alb_sg_id     = module.network.alb_sg_id
  ec2_sg_id     = module.network.ec2_sg_id
  public_subnet = module.network.public_subnet
  app_subnet    = module.network.app_subnet
}

module "database" {
  source      = "./database"
  vpc_id      = module.network.vpc_id
  db_subnet   = module.network.db_subnet
  db_sg_id    = module.network.db_sg_id
  db_password = var.db_password
}

module "monitoring" {
  source            = "./monitoring"
  monitoring_subnet = module.network.monitoring_subnet
  monitoring_sg_id  = module.network.monitoring_sg_id
}
