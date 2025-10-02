# DMZ Security Group - voor app servers
resource "aws_security_group" "dmz_app_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "dmz-app-sg"
  description = "Security group for DMZ application servers"

  # ALLEEN van ALB security group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "HTTP access from ALB only"
  }

  # SSH alleen van VPC (geen VPN meer)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Alleen van VPC (VPN verwijderd)
    description = "SSH access from VPC only"
  }

  # Node Exporter voor monitoring
  ingress {
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring_sg.id]
    description     = "Node Exporter access from monitoring server"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "dmz-app-sg"
  }
}

# Database Security Group - voor RDS
resource "aws_security_group" "db_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "db-sg"
  description = "Security group for RDS database"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.dmz_app_sg.id]
    description     = "MySQL access from DMZ app servers"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "db-sg"
  }
}

# VPN Security Group
resource "aws_security_group" "vpn_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "vpn-sg-new"
  description = "Security group for VPN server"

  # SSH toegang
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # OpenVPN toegang
  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "OpenVPN access"
  }

  # Toegang tot monitoring server vanaf VPN
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Grafana access to monitoring server"
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Prometheus access to monitoring server"
  }

  # Alle uitgaande traffic toestaan
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "vpn-sg-new"
  }
}

# Monitoring Security Group - VPN en VPC toegang
resource "aws_security_group" "monitoring_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "monitoring-sg"
  description = "Security group for monitoring server"

  # Grafana toegang vanaf VPN server en clients
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.8.0.0/24", "10.0.0.0/16"] # VPN clients + VPC
    description = "Grafana access from VPN and VPC"
  }

  # Prometheus toegang vanaf VPN server en clients
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.8.0.0/24", "10.0.0.0/16"] # VPN clients + VPC
    description = "Prometheus access from VPN and VPC"
  }

  # SSH toegang vanaf VPC (voor beheer)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "SSH access from VPC"
  }

  # Node Exporter data ophalen van app servers
  egress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]
    description = "Node Exporter access to app servers"
  }

  # Alle uitgaande traffic toestaan
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "monitoring-sg"
  }
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "alb-sg"
  description = "Security group for Application Load Balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}