
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
  alb_sg_id         = module.vpc.alb_sg_id
}


module "ecr" {
  source     = "./modules/ecr"
  region     = var.region
  ecr_name   = var.ecr_name
}


module "alb" {
  source             = "./modules/alb"
  vpc_id             = module.vpc.vpc_id
  alb_sg_id          = module.vpc.alb_sg_id
  public_subnet_ids  = module.vpc.public_subnet_ids

  private_instance_id = module.ec2.private_instance_id
}



resource "null_resource" "generate_inventory_and_copy_key" {
  provisioner "local-exec" {
    command = <<EOT
# Wait until port 22 is open
echo "⏳ Waiting for SSH on jump server..."
for i in {1..12}; do
  nc -zv ${module.ec2.jump_server_public_ip} 22 && break
  echo "🔁 Retry in 5s..."
  sleep 5
done

# Write inventory file
echo "[jump]
jump ansible_host=${module.ec2.jump_server_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/ac190-mohit/Documents/my-ec2-key.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[private]
private ansible_host=${module.ec2.private_server_private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/ac190-mohit/Documents/my-ec2-key.pem ansible_ssh_common_args='-o ProxyCommand=\"ssh -o StrictHostKeyChecking=no -i /home/ac190-mohit/Documents/my-ec2-key.pem -W %h:%p ubuntu@${module.ec2.jump_server_public_ip}\" -o StrictHostKeyChecking=no'
" > /home/ac190-mohit/Music/terraform-ansible/ansibleterraform/inventory.ini


# Secure copy SSH key to jump server
echo "📤 Copying key to jump server..."
scp -o StrictHostKeyChecking=no -i /home/ac190-mohit/Documents/my-ec2-key.pem \
  /home/ac190-mohit/Documents/my-ec2-key.pem \
  ubuntu@${module.ec2.jump_server_public_ip}:~/my-ec2-key.pem

echo "✅ SSH key copied and inventory file created!"
EOT
  }

  triggers = {
    jump_ip    = module.ec2.jump_server_public_ip
    private_ip = module.ec2.private_server_private_ip
  }

  depends_on = [module.ec2]
}






resource "null_resource" "run_ansible_playbook" {
  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook -i /home/ac190-mohit/Music/terraform-ansible/ansibleterraform/inventory.ini /home/ac190-mohit/Music/terraform-ansible/ansibleterraform/install_jenkins_docker_withpass.yml
    EOT
  }

  depends_on = [
    null_resource.generate_inventory_and_copy_key
  ]
}



data "local_file" "jenkins_password" {
  filename = "${path.root}/jenkins_output.txt"
  depends_on = [null_resource.run_ansible_playbook]
}