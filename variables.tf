variable "aws_region" {
  description = "The AWS region for the infrastructure."
  type        = string
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "AWS profile name from the ~/.aws/credentials for authentication."
  type        = string
  default     = "terraform-user"
}

variable "subnet_az" {
  description = "AZ for the public subnet"
  type        = string
  default     = "eu-central-1a"
}

variable "instance_name" {
  description = "Name for the EC2 instance."
  type        = string
  default     = "nginx-server"
}

variable "vpc_name" {
  description = "Name for the VPC."
  type        = string
  default     = "custom-vpc1"
}
