# Nginx on EC2 infrastructure

Repo consists of 2 parts: `jenkins-infra` and `nginx-app`.

`Jenkins-infra` is a terraform configuration used to manually create:
-  an EC2 instance for Jenkins master server
-  DNS A record that routes the traffic through ALB to the EC2 instance
-  SG that restricts access only from ALB to the EC2 instance
-  SG for Jenkins agents created by Jenkins master EC2 plugin

Jenkins-infra uses ‘terraform_remote_state’ to get the data needed to configure the
server with ALB from nginx-app.



`Nginx-app` is terraform configuration that should be used only with
CI/CD tools - Github Actions or Jenkins. The terraform is configured to create:
- VPC with 2 public and 1 private subnets
- Internet Gateway and NAT Gateway
- SG and Routes necessary for controlling traffic in VPC
- ALB for directing traffic to Nginx and Jenkins servers
- Route53 hosted zone and DNS A record for the Nginx server

Nginx-app contains a github workflow file and a Jenkinsfile that automatically creates the infrastructure on push or pull request to the main branch.

<b>
The version of Terraform used for this repository is v1.12.2.