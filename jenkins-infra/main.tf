data "terraform_remote_state" "nginx_app_state" {
  backend = "s3"
  config = {
    bucket = var.nginx_bucket_name
    key    = var.nginx_state_key
    region = var.nginx_aws_region
    profile = var.aws_profile
  }
}
