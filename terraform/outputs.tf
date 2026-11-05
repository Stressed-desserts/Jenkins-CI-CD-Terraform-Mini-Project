output "instance_public_ip" {
  description = "Public IP address of the deployed application host"
  value       = aws_instance.app_server.public_ip
}

output "vpc_id" {
  description = "Target VPC ID"
  value       = aws_vpc.main_vpc.id
}

output "application_endpoint" {
  description = "Access URL for application service"
  value       = "http://${aws_instance.app_server.public_ip}:5000"
}
