resource "aws_db_subnet_group" "main" {
  name       = "rds-subnet-group"
  subnet_ids = [var.db_subnet]
}

resource "aws_db_instance" "main" {
  identifier         = "app-db"
  engine             = "mysql"
  instance_class     = "db.t3.micro"
  username           = "admin"
  password           = var.db_password
  allocated_storage  = 20
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  skip_final_snapshot = true
}
