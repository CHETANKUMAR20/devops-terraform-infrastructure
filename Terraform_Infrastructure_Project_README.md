🚀 Terraform Infrastructure Provisioning Project
📌 Overview

This project demonstrates Infrastructure as Code (IaC) using Terraform to provision a fully automated AWS environment including networking, compute resources, IAM roles, and remote state management.

The entire infrastructure lifecycle was managed using version-controlled Terraform code with zero manual AWS console configuration.

🏗 Architecture Components

Custom VPC (10.0.0.0/16)

Public Subnet with auto-assign public IP

Internet Gateway attached to VPC

Public Route Table (0.0.0.0/0 → IGW)

Security Group (SSH – 22, App Port – 5000)

EC2 Instance deployed inside public subnet

IAM Role attached to EC2 (ECR access)

Remote State stored in S3 backend

S3 Bucket versioning enabled

📁 Project Structure
devops-terraform-infrastructure/
│
├── backend.tf
├── provider.tf
├── vpc.tf
├── subnet.tf
├── route-table.tf
├── security-group.tf
├── iam.tf
├── ec2.tf
├── variables.tf
├── terraform.tfvars
├── output.tf
└── README.md

🔐 Remote Backend Configuration

Terraform state is stored remotely using S3 backend:

S3 bucket created manually

Versioning enabled to prevent accidental state loss

State file stored under: terraform-infra/terraform.tfstate

Backend initialized using:

terraform init -reconfigure

⚙️ Deployment Workflow
1️⃣ Initialize
terraform init

2️⃣ Validate Configuration
terraform validate

3️⃣ Preview Changes
terraform plan

4️⃣ Deploy Infrastructure
terraform apply

5️⃣ Verify State
terraform state list

6️⃣ Destroy Infrastructure
terraform destroy

✅ Validation Performed

Verified resources via AWS Console

Verified infrastructure using AWS CLI

Confirmed no resource drift using:

terraform plan


Destroyed all infrastructure and confirmed zero billing risk

📊 Key Achievements

Fully automated AWS infrastructure provisioning

Version-controlled infrastructure code

Remote state management with versioning protection

Clean separation of infrastructure layers (networking, security, compute, IAM)

Complete lifecycle testing (init → apply → destroy)

Clean resource audit using AWS CLI after destroy

🧠 Lessons Learned

Importance of remote backend for collaboration

Infrastructure drift detection using Terraform plan

Proper cleanup to avoid unnecessary AWS billing

IAM role attachment best practices

Public subnet routing and Internet Gateway setup

Terraform file structure organization (production-style layout)

🎯 Outcome

Successfully provisioned and destroyed a complete AWS environment using Terraform with zero manual console configuration.

Demonstrated production-level Infrastructure as Code practices suitable for DevOps Engineer, Cloud Engineer, and Infrastructure Engineer roles.

👨‍💻 Author

Chetan Kumar
DevOps Engineer | Cloud
Bengaluru, India
GitHub: https://github.com/CHETANKUMAR20