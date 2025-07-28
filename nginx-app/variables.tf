variable "aws_region" {
  description = "The AWS region for the infrastructure."
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1,2}$", var.aws_region))
    error_message = "The AWS region must be in a valid format (e.g., 'us-east-1', 'eu-central-1')."
  }
}

variable "subnet_az_a" {
  description = "AZ for the public subnet"
  type        = string
  default     = "eu-central-1a"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1,2}[a-z]$", var.subnet_az_a))
    error_message = "The Availability Zone (AZ) must be in a valid AWS format (e.g., 'us-east-1a', 'eu-central-1b'). It should start with a region prefix and end with a lowercase letter."
  }
}

variable "subnet_az_b" {
  description = "AZ for the public subnet"
  type        = string
  default     = "eu-central-1b"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1,2}[a-z]$", var.subnet_az_b))
    error_message = "The Availability Zone (AZ) must be in a valid AWS format (e.g., 'us-east-1a', 'eu-central-1b'). It should start with a region prefix and end with a lowercase letter."
  }
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

variable "instance_type" {
  description = "Instance type for the EC2."
  type        = string
  default     = "t2.micro"

  validation {
    condition     = length(var.instance_type) >= 7 && can(regex("\\.", var.instance_type)) && !can(regex("\\s", var.instance_type))
    error_message = "The instance type must be a valid format (e.g., 't2.micro'), be at least 7 characters long, and contain no spaces."
  }
}

variable "domain_name" {
  description = "The domain name for the Route 53 hosted zone."
  type        = string

  validation {
    condition     = length(regexall("\\.", var.domain_name)) >= 1 && !can(regex("\\s", var.domain_name))
    error_message = "The domain name must contain at least one dot (e.g., 'example.com') and cannot contain spaces."
  }
}

variable "www_record_type" {
  description = "Type of the DNS record to create."
  type        = string
  default     = "A"

  validation {
    condition     = contains(["A", "CNAME"], var.www_record_type)
    error_message = "The www_record_type must be either 'A' (for IPv4 address) or 'CNAME' (for canonical name)."
  }
}

variable "www_record_ttl" {
  description = "Instance type for the EC2."
  type        = number
  default     = 60

  validation {
    condition     = var.www_record_ttl >= 60 && var.www_record_ttl <= 86400
    error_message = "The www_record_ttl must be a positive integer between 60 and 86400 seconds."
  }
}

variable "terraform_role_arn" {
  description = "ARN of the terraform role to assume."
  type        = string
  default     = "arn:aws:iam::038462790533:role/TerraformRole"

  validation {
    condition     = can(regex("^arn:aws:iam::\\d{12}:role/[a-zA-Z0-9+=,.@_-]{1,64}$", var.terraform_role_arn))
    error_message = "The 'terraform_role_arn' variable must be a valid AWS IAM Role ARN, e.g., 'arn:aws:iam::123456789012:role/MyRole'."
  }
}