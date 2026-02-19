resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "devops-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "devops-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "devops-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# STEP 1 – Add Security Group to main.tf
resource "aws_security_group" "devops_sg" {
  name        = "devops-sg"
  description = "Allow SSH and App traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App Port"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-sg"
  }
}


# STEP 2 – Create IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "devops-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "devops-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# STEP 3 – Launch EC2 via Terraform
resource "aws_instance" "devops_ec2" {
  ami                         = "ami-0f5ee92e2d63afc18" # Amazon Linux 2023 (ap-south-1)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name = "Devops-CI-CD"

  user_data = <<-EOF
              #!/bin/bash

              exec > /var/log/user-data.log 2>&1
              set -x

              apt update -y
              apt install -y docker.io awscli

              systemctl start docker
              systemctl enable docker

              sleep 30

              aws ecr get-login-password --region ap-south-1 \
              | docker login --username AWS --password-stdin 381492025611.dkr.ecr.ap-south-1.amazonaws.com

              docker pull 381492025611.dkr.ecr.ap-south-1.amazonaws.com/devops-ci-cd-project:latest

              docker run -d -p 5000:5000 --name devops-app \
              381492025611.dkr.ecr.ap-south-1.amazonaws.com/devops-ci-cd-project:latest
              EOF

  tags = {
    Name = "devops-terraform-ec2"
  }
}

