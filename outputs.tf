output "instance_public_ip" {
  description = "Public IP address of the EC2 instance (if assigned)."
  value       = module.my_ec2_instance.instance_public_ip
}

output "fqdn_www" {
  description = "The fully qualified domain name for the nginx server."
  value       = aws_route53_record.www.name
}