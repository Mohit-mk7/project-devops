resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "aws_security_group" "jump_sg" {
  name        = "jump-sg"
  description = "Allow SSH from anywhere"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.jump_ssh_cidr]
  }


  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.jump_ssh_cidr]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Allow SSH from jump server"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jump_sg.id]
  }


  ingress {
        from_port   = 3005
        to_port     = 3005
        protocol    = "tcp"
    security_groups = [var.alb_sg_id] # allow ALB to reach app
  }

  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jump" {
  ami                         = var.jump_ami
  instance_type               = var.jump_instance_type
  subnet_id                   = var.public_subnet
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids      = [aws_security_group.jump_sg.id]
  tags = { Name = "jump-server" }
}



resource "aws_iam_role" "ecr_access" {
  name = "ecr-access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_full_access" {
  role       = aws_iam_role.ecr_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecr_full_access" {
  role       = aws_iam_role.ecr_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_instance_profile" "ecr_profile" {
  name = "ecr-access-profile"
  role = aws_iam_role.ecr_access.name
}







resource "aws_instance" "private" {
  ami                    = var.private_ami
  instance_type          = var.private_instance_type
  subnet_id              = var.private_subnet
  key_name               = aws_key_pair.ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ecr_profile.name
  tags = {
    Name = "private-server"
  }
}



resource "local_file" "private_key" {
  content              = tls_private_key.ec2_key.private_key_pem
  filename             = "/home/ac190-mohit/Documents/${var.key_name}.pem"
  file_permission      = "0400"
  directory_permission = "0700"
}




