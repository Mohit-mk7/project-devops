variable "key_name" {
  description = "Name to assign to the EC2 key pair and PEM file"
  type        = string
}

variable "jump_ami" {
  type = string
}

variable "private_ami" {
  type = string
}

variable "jump_instance_type" {
  type = string
}

variable "private_instance_type" {
  type = string
}

variable "jump_ssh_cidr" {
  type = string
}

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
}


variable "ecr_name" {
  description = "Name of the ECR repository to create"
  type        = string
}
