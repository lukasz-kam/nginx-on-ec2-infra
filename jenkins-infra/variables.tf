variable "nginx_aws_region" {
  description = "The AWS region of the nginx backend bucket."
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1,2}$", var.nginx_aws_region))
    error_message = "The AWS region must be in a valid format (e.g., 'us-east-1', 'eu-central-1')."
  }
}

variable "aws_region" {
  description = "AWS region for Jenkins infrastructure."
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1,2}$", var.aws_region))
    error_message = "The AWS region must be in a valid format (e.g., 'us-east-1', 'eu-central-1')."
  }
}

variable "nginx_state_key" {
  description = "State key name of the nginx backend."
  type        = string
  default     = "terraform/terraform.tfstate"
}

variable "nginx_bucket_name" {
  description = "State key name of the nginx backend."
  type        = string
  default     = "awsinfra-tfstate-038462790533"
}

variable "aws_profile" {
  description = "AWS profile name from the ~/.aws/credentials for authentication."
  type        = string
  default     = "terraform-user"
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

variable "instance_type" {
  description = "Instance type for the EC2."
  type        = string
  default     = "t2.micro"

  validation {
    condition     = length(var.instance_type) >= 7 && can(regex("\\.", var.instance_type)) && !can(regex("\\s", var.instance_type))
    error_message = "The instance type must be a valid format (e.g., 't2.micro'), be at least 7 characters long, and contain no spaces."
  }
}

variable "ami_id" {
  description = "AMI id for Jenkins instance."
  type        = string
  default     = "ami-03d4b5fc380d691b4"
}

variable "jenkins_subdomain" {
  description = "The subdomain for the jenkins server."
  type        = string

  validation {
    condition     = length(regexall("\\.", var.jenkins_subdomain)) >= 1 && !can(regex("\\s", var.jenkins_subdomain))
    error_message = "The jenkins_subdomain name must contain at least one dot (e.g., 'example.com') and cannot contain spaces."
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

variable "allowed_cidr" {
  description = "IPv4 CIDR block to whitelist for connection to the jenkins server."
  type        = string

  validation {
    condition     = can(cidrhost("${var.allowed_cidr}", 0))
    error_message = "The 'server_ip_address' must be a valid IPv4 CIDR block (e.g., '192.168.1.0/24')."
  }
}

variable "key_pair_name" {
  description = "SSH key pair name."
  type        = string
  default     = "jenkins-master-key"
}

variable "key_file_name" {
  description = "Name of the key pair file."
  type        = string
  default     = "jenkins-ssh-key.pem"
}