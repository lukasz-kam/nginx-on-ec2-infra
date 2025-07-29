pipeline {
    agent {
        docker {
            image 'hashicorp/terraform:latest'
            args '--entrypoint=""'
            label 'terraform-docker'
        }
    }

    environment {
        AWS_REGION            = 'eu-central-1'
        TERRAFORM_WORKING_DIR = 'nginx-app'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    checkout scm
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    withCredentials([aws(credentialsId: 'jenkins-aws-credentials')]) {
                        dir(env.TERRAFORM_WORKING_DIR) {
                            sh 'terraform init -input=false'
                        }
                    }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                script {
                    withCredentials([aws(credentialsId: 'jenkins-aws-credentials')]) {
                        dir(env.TERRAFORM_WORKING_DIR) {
                            sh 'terraform validate'
                        }
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    withCredentials([aws(credentialsId: 'jenkins-aws-credentials')]) {
                        dir(env.TERRAFORM_WORKING_DIR) {
                            sh 'terraform plan -no-color -out=tfplan'
                        }
                    }
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: "${env.TERRAFORM_WORKING_DIR}/tfplan", fingerprint: true, allowEmptyArchive: true
                }
            }
        }

        stage('Terraform Apply Confirmation') {
            when {
                expression { env.BRANCH_NAME == 'feature/jenkins-pipeline' }
            }
            steps {
                script {
                    withCredentials([aws(credentialsId: 'jenkins-aws-credentials')]) {
                        dir(env.TERRAFORM_WORKING_DIR) {
                            input {
                                message "Proceed with Terraform Apply for '${env.BRANCH_NAME}'?"
                                ok "Yes, apply changes"
                            }
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }
    }
}