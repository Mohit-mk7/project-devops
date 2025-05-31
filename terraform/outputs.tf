output "jump_server_public_ip" {
  value = module.ec2.jump_server_public_ip
}

output "private_server_private_ip" {
  value = module.ec2.private_server_private_ip
}


output "app_alb_dns" {
  description = "Application Load Balancer DNS name"
  value       = module.alb.alb_dns_name
}



output "jenkins_admin_password" {
  value       = data.local_file.jenkins_password.content
  description = "Jenkins initial admin password"
}




