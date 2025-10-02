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

variable "key_pair_name" {
  description = "The name of the existing EC2 key pair to use"
  type        = string
  default     = "ec2_anouar" # Aangepast naar jouw key name
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "SuperVeiligWachtwoord123!"
}

variable "volume_type" {
  description = "Type of EBS volume"
  type        = string
  default     = "gp3" # of "gp2"
}

variable "volume_size" {
  description = "Size of EBS volume in GB"
  type        = number
  default     = 8
}

# Amazon Linux 2 AMI - WERKT ZEKER MET t3.micro
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}