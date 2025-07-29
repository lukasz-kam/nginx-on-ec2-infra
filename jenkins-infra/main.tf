data "terraform_remote_state" "nginx_app_state" {
  backend = "s3"
  config = {
    bucket  = var.nginx_bucket_name
    key     = var.nginx_state_key
    region  = var.nginx_aws_region
    profile = var.aws_profile
  }
}

data "aws_lb" "main_alb" {
  name = data.terraform_remote_state.nginx_app_state.outputs.alb_name
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-instance-sg"
  description = "Allow HTTP access from ALB"
  vpc_id      = data.terraform_remote_state.nginx_app_state.outputs.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.nginx_app_state.outputs.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "jenkins-sg"
    ManagedBy = "Terraform"
  }
}

resource "aws_instance" "jenkins_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.terraform_remote_state.nginx_app_state.outputs.private_subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = file("${path.module}/scripts/jenkins-install.sh")

  tags = {
    Name      = "JenkinsServer"
    ManagedBy = "Terraform"
  }
}

resource "aws_lb_target_group" "jenkins_tg" {
  name        = "jenkins-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.nginx_app_state.outputs.vpc_id
  target_type = "instance"

  health_check {
    path                = "/login"
    port                = "8080"
    protocol            = "HTTP"
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name      = "JenkinsTargetGroup"
    ManagedBy = "Terraform"
  }
}

resource "aws_lb_target_group_attachment" "jenkins_attachment" {
  target_group_arn = aws_lb_target_group.jenkins_tg.arn
  target_id        = aws_instance.jenkins_server.id
  port             = 8080
}

resource "aws_lb_listener_rule" "jenkins_rule" {
  listener_arn = data.terraform_remote_state.nginx_app_state.outputs.http_listener_arn
  priority     = 900

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }

  condition {
    host_header {
      values = [
        var.jenkins_subdomain
      ]
    }
  }

  condition {
    source_ip {
      values = [var.allowed_cidr]
    }
  }

  tags = {
    Name      = "JenkinsAlbRule"
    ManagedBy = "Terraform"
  }
}