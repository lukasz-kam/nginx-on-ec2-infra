#!/bin/bash

sudo yum update –y
sudo yum install wget -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
sudo yum install java-17-amazon-corretto -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sleep 10
echo "***JENKINS PASSWORD START***"
cat /var/lib/jenkins/secrets/initialAdminPassword
echo "***JENKINS PASSWORD END***"