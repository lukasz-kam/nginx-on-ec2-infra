module "my_s3_bucket" {
  source = "git@git.epam.com:lukasz_kaminski1/terraform-modules.git//modules/s3?ref=main"

  bucket_prefix = "ec2bucket"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = var.vpc_name
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.subnet_az

  tags = {
    Name      = "${var.vpc_name}_PublicSubnet"
    ManagedBy = "Terraform"
  }

}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "${var.vpc_name}_IGW"
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "${var.vpc_name}_PublicRT"
    ManagedBy = "Terraform"
  }
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_route_table.id
}