resource "aws_route53_record" "jenkins" {
  zone_id = data.terraform_remote_state.nginx_app_state.outputs.route_zone_id
  name    = var.jenkins_subdomain
  type    = var.www_record_type

  alias {
    name                   = data.aws_lb.main_alb.dns_name
    zone_id                = data.aws_lb.main_alb.zone_id
    evaluate_target_health = true
  }
}