

provider "aws" {
  region = var.aws_region
}
terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "3.1.0"
    }
  }
}
provider "null" {
}

# --------------------------------------------------------------------------------------------------------------------
# TERRAFORM STATEFILE
# --------------------------------------------------------------------------------------------------------------------
terraform {
  backend "s3" {
 	encrypt = true
 	bucket = "ozsudemoan"
 	region = "ap-south-1"
 	key = "demosetup/terraform.tfstate"
    }
}


# --------------------------------------------------------------------------------------------------------------------
# VPC NETWORKING 
# --------------------------------------------------------------------------------------------------------------------
module "vpc_networking" {
    source = "./modules/vpc_networking"

    prefix_name             = var.name_prefix
    avail_zones             = var.avail_zones
    prod_vpc_id             = var.prod_vpc_id
    devOps_vpc_id           = var.devOps_vpc_id
    tgw_id                  = var.tgw_id
    bastion_sg_id           = var.bastion_sg_id
}

# ----------------------------------------------------------------------------------
# EC2 INSTANCE 
# ----------------------------------------------------------------------------------
module "bastion" {
  source = "./modules/bastion"

  name_prefix                     = var.name_prefix
  ami_id                          = var.ami_id
  prod_vpc_id                     = var.prod_vpc_id
  instance_type_4_16              = var.instance_type_4_16 
  subnets                         = module.vpc_networking.private_subnet_id
  key_pair_name_bastion           = var.key_pair_name_bastion
  disk_size                       = var.disk_size

}


