output "fqdn_www" {
  description = "The fully qualified domain name for the nginx server."
  value       = aws_route53_record.www.name
}