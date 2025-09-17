variable "region" {
  description = "AWS regio waar resources gecreëerd worden"
  type        = string
  default     = "eu-central-1"
}

# Database
variable "db_password" {
  description = "Wachtwoord voor de MySQL database"
  type        = string
  sensitive   = true
}

# VPC & Network
variable "vpc_cidr" {
  description = "CIDR block voor de VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs voor public subnets per AZ"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.6.0/24"]
}

variable "app_subnet_cidrs" {
  description = "CIDRs voor application subnets per AZ"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.7.0/24"]
}

variable "db_subnet_cidrs" {
  description = "CIDRs voor database subnets per AZ"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.8.0/24"]
}

variable "monitoring_subnet_cidrs" {
  description = "CIDRs voor monitoring subnets per AZ"
  type        = list(string)
  default     = ["10.0.5.0/28", "10.0.9.0/28"]
}
