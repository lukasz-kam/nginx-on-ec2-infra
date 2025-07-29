pipeline {
    agent {
        docker {
            image 'hashicorp/terraform:latest'
            args '-u root --entrypoint=""'
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
                        sshagent(credentials: ['gitlab-ssh-key']) {
                            sh 'mkdir -p /root/.ssh'
                            sh 'chmod 700 /root/.ssh'
                            sh 'ssh-keyscan git.epam.com >> /root/.ssh/known_hosts'
                            sh 'chmod 600 /root/.ssh/known_hosts'
                            dir(env.TERRAFORM_WORKING_DIR) {
                                sh 'terraform init -input=false'
                            }
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

        stage('Terraform Apply') {
            when {
                expression { env.BRANCH_NAME == 'main' }
            }
            steps {
                script {
                    withCredentials([aws(credentialsId: 'jenkins-aws-credentials')]) {
                        dir(env.TERRAFORM_WORKING_DIR) {
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}