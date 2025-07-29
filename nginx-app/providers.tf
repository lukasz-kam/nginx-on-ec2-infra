terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "awsinfra-tfstate-038462790533"
    key          = "terraform/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true

    assume_role = {
      role_arn     = "arn:aws:iam::038462790533:role/TerraformRole"
      session_name = "terraform-backend-project-session"
    }
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = var.terraform_role_arn
    session_name = "terraform-nginx-project-session"
  }
}
