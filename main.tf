module "my_s3_bucket" {
  source = "git@git.epam.com:lukasz_kaminski1/terraform-modules.git//modules/s3?ref=main"

  bucket_prefix = "ec2bucket"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

 tags = {
    Name = var.vpc_name
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.subnet_az

}
