resource "aws_db_subnet_group" "default" {
  name       = "db-subnet-group"
  subnet_ids = [var.db_subnet]

  tags = { Name = "db-subnet-group" }
}

resource "aws_db_instance" "mysql" {
  identifier              = "mydb-instance"
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  name                    = "mydb"
  username                = "admin"
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [var.db_sg_id]
  skip_final_snapshot     = true
}
