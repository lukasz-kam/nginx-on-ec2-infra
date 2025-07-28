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