output "jenkins_fqdn" {
  description = "The fully qualified domain name for the jenkins server."
  value       = aws_route53_record.jenkins.name
}