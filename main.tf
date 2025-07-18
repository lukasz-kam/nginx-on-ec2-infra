data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "my_s3_bucket" {
  source = "git@git.epam.com:lukasz_kaminski1/terraform-modules.git//modules/s3?ref=main"

  bucket_prefix = "ec2bucket"
}

module "my_ec2_instance" {
  source = "git@git.epam.com:lukasz_kaminski1/terraform-modules.git//modules/ec2?ref=main"

  instance_name      = var.instance_name
  ami_id             = data.aws_ami.amazon.id
  instance_type      = var.instance_type
  subnet_id          = aws_subnet.public.id
  assign_public_ip   = true
  security_group_ids = [aws_security_group.nginx_sg.id]

  user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install nginx -y
            sudo systemctl start nginx
            sudo systemctl enable nginx
            sudo bash -c 'echo "<h1>Nginx on EC2</h1>" > /usr/share/nginx/html/index.html'
            EOF
}

resource "aws_security_group" "nginx_sg" {
  name        = "nginx-web-access-sg"
  description = "Allow HTTP access to Nginx web server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
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
    Name      = "nginx-http-sg"
    ManagedBy = "Terraform"
  }
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