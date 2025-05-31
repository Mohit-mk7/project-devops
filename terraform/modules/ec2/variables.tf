variable "vpc_id" {}
variable "public_subnet" {}
variable "private_subnet" {}

variable "key_name" {
  type        = string
  description = "Name to assign to the EC2 key pair and PEM file"
}

variable "jump_ami" {
  type    = string
  default = "ami-0f9de6e2d2f067fca"
}

variable "private_ami" {
  type    = string
  default = "ami-0f9de6e2d2f067fca"
}

variable "jump_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "private_instance_type" {
  type    = string
  default = "t2.small"
}

variable "jump_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}


variable "alb_sg_id" {
  description = "ALB security group ID to allow traffic from ALB to private server"
  type        = string
}

output "ecr_role_name" {
  value = aws_iam_role.ecr_access.name
}



