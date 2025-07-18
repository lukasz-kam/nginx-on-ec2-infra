# Nginx on EC2 infrastructure

Repo contains Terraform code that:
  - creates custom VPC with public subnet
  - creates internet gateway and route table
  - uses a module to create a S3 bucket
  - uses a module to create EC2 instance with NGINX server configured to show image from the S3 bucket
  - creates all necessary IAM roles and Security Groups


The version of Terraform used for this repository is v1.12.2.