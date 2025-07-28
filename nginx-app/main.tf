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

  instance_name        = var.instance_name
  ami_id               = data.aws_ami.amazon.id
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.private_a.id
  assign_public_ip     = false
  security_group_ids   = [aws_security_group.nginx_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

  user_data = templatefile("${path.module}/scripts/user_data_script.sh", {
    S3_BUCKET_NAME = module.my_s3_bucket.bucket_name
    S3_IMAGE_KEY   = local.object_key
  })
}

locals {
  source_file_path = "./images/logo.png"
  object_key       = "logo.png"
}

resource "aws_s3_object" "file_upload" {
  bucket = module.my_s3_bucket.bucket_name
  key    = "public/${local.object_key}"
  source = local.source_file_path
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-access-sg"
  description = "Allow HTTP access to ALB"
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
    Name      = "alb-http-sg"
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "nginx_sg" {
  name        = "app-instance-sg"
  description = "Allow HTTP access from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-sg"
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

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.subnet_az_a

  tags = {
    Name      = "${var.vpc_name}_PublicSubnetA"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.subnet_az_b

  tags = {
    Name      = "${var.vpc_name}_PublicSubnetB"
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.subnet_az_a

  tags = {
    Name      = "${var.vpc_name}_PrivateSubnetA"
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

resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main_igw]

  tags = {
    Name      = "NAT_EIP"
    ManagedBy = "Terraform"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_a.id

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = "NAT_Gateway"
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

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name      = "${var.vpc_name}_PrivateRT"
    ManagedBy = "Terraform"
  }
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

resource "aws_route_table_association" "public_a_association" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_b_association" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_a_association" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3-read-only-policy"
  description = "Allows EC2 instance to read objects from a specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          module.my_s3_bucket.s3_bucket_arn,
          "${module.my_s3_bucket.s3_bucket_arn}/*"
        ]
      },
    ]
  })

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-read-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "s3_read_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2-s3-read-profile"
  role = aws_iam_role.ec2_s3_role.name

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_lb" "app_lb" {
  name               = "my-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name      = "MyAppALB"
    ManagedBy = "Terraform"
  }
}

resource "aws_lb_target_group" "nginx_tg" {
  name        = "nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
    matcher             = "200"
  }

  tags = {
    Name      = "NginxTG"
    ManagedBy = "Terraform"
  }
}

resource "aws_lb_target_group_attachment" "nginx_attachment" {
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = module.my_ec2_instance.instance_id
  port             = 80
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }

  tags = {
    Name      = "HTTPListener"
    ManagedBy = "Terraform"
  }
}