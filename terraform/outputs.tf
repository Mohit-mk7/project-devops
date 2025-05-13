output "jump_server_public_ip" {
  value = module.ec2.jump_server_public_ip
}

output "private_server_private_ip" {
  value = module.ec2.private_server_private_ip
}
