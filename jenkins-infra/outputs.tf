output "jenkins_fqdn" {
  description = "The fully qualified domain name for the jenkins server."
  value       = aws_route53_record.jenkins.name
}

output "jenkins_agent_security_group_id" {
  description = "The ID of the Jenkins Agent Security Group."
  value       = aws_security_group.jenkins_agent_sg.id
}