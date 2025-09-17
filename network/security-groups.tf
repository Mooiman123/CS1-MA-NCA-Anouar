resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id
  description = "ALB SG"
  ingress { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  egress { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "alb-sg" }
}
output "alb_sg_id" { value = aws_security_group.alb_sg.id }

# EC2 SG
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id
  ingress { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  egress { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "ec2-sg" }
}
output "ec2_sg_id" { value = aws_security_group.ec2_sg.id }

# DB SG
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id
  ingress { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = ["10.0.0.0/16"] }
  egress { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "db-sg" }
}
output "db_sg_id" { value = aws_security_group.db_sg.id }

# Monitoring SG
resource "aws_security_group" "monitoring_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "monitoring-sg" }
}
output "monitoring_sg_id" { value = aws_security_group.monitoring_sg.id }
