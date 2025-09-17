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
}

module "compute" {
  source           = "./compute"
  vpc_id           = module.network.vpc_id
  public_subnet_a  = module.network.public_a_subnet
  public_subnet_b  = module.network.public_b_subnet
  ec2_sg_id        = module.network.ec2_sg_id
  alb_sg_id        = module.network.alb_sg_id
}

module "dns" {
  source       = "./dns"
  alb_dns_name = module.compute.alb_dns_name
  alb_zone_id  = module.compute.alb_zone_id
}
