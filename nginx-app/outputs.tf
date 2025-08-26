output "fqdn_www" {
  description = "The fully qualified domain name for the nginx server."
  value       = aws_route53_record.www.name
}

output "vpc_id" {
  description = "ID of the vpc."
  value       = aws_vpc.main.id
}

output "alb_sg_id" {
  description = "ALB security group id."
  value       = aws_security_group.alb_sg.id
}

output "private_subnet_id" {
  description = "Private subnet id."
  value       = aws_subnet.private_a.id
}

output "public_subnet_a_id" {
  description = "Private subnet id."
  value       = aws_subnet.public_a.id
}

output "alb_name" {
  description = "ALB name."
  value       = aws_lb.app_lb.name
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener on the ALB."
  value       = aws_lb_listener.http_listener.arn
}

output "route_zone_id" {
  description = "Route53 zone id."
  value       = aws_route53_zone.main.zone_id
}