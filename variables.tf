variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "volume_type" {
  description = "Type of EBS volume"
  type        = string
  default     = "gp3"
}

variable "volume_size" {
  description = "Size of EBS volume in GB"
  type        = number
  default     = 8
}

variable "DB_USERNAME" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "DB_PASSWORD" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "GRAFANA_ADMIN_PASSWORD" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "KEY_PAIR_NAME" {
  description = "AWS Key Pair name"
  type        = string
}

variable "OPENVPN_AMI" {
  description = "AMI ID for OpenVPN server"
  type        = string
}

variable "WEBSERVER_AMI" {
  description = "AMI ID for web servers"
  type        = string
}