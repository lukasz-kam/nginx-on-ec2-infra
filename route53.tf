resource "aws_route53_zone" "main" {
  name = var.domain_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = var.www_record_type
  ttl     = var.www_record_ttl
  records = [module.my_ec2_instance.instance_public_ip]
}