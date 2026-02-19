terraform {
  backend "s3" {
    bucket  = "chetan-terraform-state-bucket"
    key     = "terraform-infra/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}
