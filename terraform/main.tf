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





resource "null_resource" "generate_inventory_and_copy_key" {
  provisioner "local-exec" {
    command = <<EOT
# Write inventory.ini
echo "[jump]
jump ansible_host=${module.ec2.jump_server_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/ac190-mohit/Documents/my-ec2-key.pem

[private]
private ansible_host=${module.ec2.private_server_private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/ac190-mohit/Documents/my-ec2-key.pem ansible_ssh_common_args='-o ProxyCommand=\"ssh -i /home/ac190-mohit/Documents/my-ec2-key.pem -W %h:%p ubuntu@${module.ec2.jump_server_public_ip}\"'
" > /home/ac190-mohit/Documents/ansibleterraform/inventory.ini

# Copy SSH key to jump server
scp -o StrictHostKeyChecking=no -i /home/ac190-mohit/Documents/my-ec2-key.pem /home/ac190-mohit/Documents/my-ec2-key.pem ubuntu@${module.ec2.jump_server_public_ip}:~/my-ec2-key.pem
EOT
  }

  triggers = {
    jump_ip    = module.ec2.jump_server_public_ip
    private_ip = module.ec2.private_server_private_ip
  }

  depends_on = [module.ec2]
}