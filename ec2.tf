resource "aws_instance" "devops_ec2" {
  ami                         = "ami-0f5ee92e2d63afc18"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name                    = var.key_name

  user_data = <<-EOF
              #!/bin/bash

              dnf update -y
              dnf install -y docker awscli

              systemctl start docker
              systemctl enable docker

              sleep 30

              aws ecr get-login-password --region ${var.region} \
              | docker login --username AWS --password-stdin ${var.ecr_repository_url}

              docker pull ${var.ecr_repository_url}:latest

              docker run -d -p 5000:5000 --name devops-app \
              ${var.ecr_repository_url}:latest
              EOF

  tags = {
    Name = "devops-terraform-ec2"
  }
}
