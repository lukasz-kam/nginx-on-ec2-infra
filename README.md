# 🌐 Nginx Web Server on AWS with CI/CD & Jenkins

This project provisions a complete **AWS infrastructure** using **Terraform** and deploys a simple static website served by **Nginx** on an **EC2 instance**.
The infrastructure is fully automated via **GitHub Actions CI/CD**. The repository also includes a setup for **Jenkins** (both on EC2 and Docker).

---

## 📐 Architecture

- **Route53**: DNS record pointing to an Application Load Balancer (ALB)
- **ALB (Application Load Balancer)**: Distributes traffic to EC2 instances
- **EC2 instance**: Runs Nginx serving a static website
- **S3 bucket**: Stores static content for the website
- **Networking**: VPC, subnets, NAT Gateway, route tables, security groups

👉 The flow:
`Route53 DNS → ALB → EC2 (Nginx) → Static website`

---

## 🛠️ Tech Stack

- **Terraform**
  - AWS resources: ALB, EC2, S3, Route53, Networking components
- **CI/CD**
  - GitHub Actions workflow
- **Jenkins**
  - Terraform configuration to provision a Jenkins server on EC2
  - Docker & Docker Compose setup for Jenkins Master and Agents
  - Three Jenkins pipelines:
    - Declarative pipeline (`Jenkinsfile`)
    - Scripted pipeline (`Jenkinsfile-scripted`)
    - Scripted pipeline with Docker agents (`Jenkinsfile-docker`)
- **Docker**

---

