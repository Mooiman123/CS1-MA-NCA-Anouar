# VPC Output
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# App Servers
output "app_instance_ips" {
  description = "Private IPs of app instances"
  value       = aws_instance.app[*].private_ip
}

# VPN Server
output "vpn_public_ip" {
  description = "Public IP of VPN server"
  value       = aws_instance.vpn.public_ip
}

output "vpn_ssh_command" {
  description = "SSH command to connect to VPN server"
  value       = "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.vpn.public_ip}"
}

# Database
output "db_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.endpoint
}

# Load Balancer
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

# Monitoring
output "monitoring_private_ip" {
  description = "Private IP of monitoring server"
  value       = aws_instance.monitoring.private_ip
}

# NAT Gateway
output "nat_gateway_ip" {
  description = "NAT Gateway public IP"
  value       = aws_eip.nat.public_ip
}

# Security Groups
output "dmz_sg_id" {
  description = "DMZ Security Group ID"
  value       = aws_security_group.dmz_app_sg.id
}

output "vpn_sg_id" {
  description = "VPN Security Group ID"
  value       = aws_security_group.vpn_sg.id
}