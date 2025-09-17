variable "vpc_id" {}
variable "db_subnet" {
  type = list(string)
}
variable "db_sg_id" {}
variable "db_password" {}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "case-db-subnet"
  subnet_ids = var.db_subnet
  tags = { Name = "case-db-subnet" }
}

resource "aws_db_instance" "db" {
  identifier              = "case-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [var.db_sg_id]
  username                = "admin"
  password                = var.db_password
  publicly_accessible     = false
  skip_final_snapshot     = true
  multi_az                = true
}
