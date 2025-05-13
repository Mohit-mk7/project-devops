module "vpc" {
  source = "./modules/vpc"
  region = var.region
}

module "ec2" {
  source            = "./modules/ec2"
  vpc_id            = module.vpc.vpc_id
  public_subnet     = module.vpc.public_subnet_id
  private_subnet    = module.vpc.private_subnet_id
  key_name          = var.key_name
  jump_ami          = var.jump_ami
  private_ami       = var.private_ami
  jump_instance_type = var.jump_instance_type
  private_instance_type = var.private_instance_type
  jump_ssh_cidr     = var.jump_ssh_cidr
}


module "ecr" {
  source     = "./modules/ecr"
  region     = var.region
  ecr_name   = var.ecr_name
}

