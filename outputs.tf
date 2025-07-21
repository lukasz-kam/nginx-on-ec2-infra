output "instance_public_ip" {
  description = "Public IP address of the EC2 instance (if assigned)."
  value       = module.my_ec2_instance.instance_public_ip
}