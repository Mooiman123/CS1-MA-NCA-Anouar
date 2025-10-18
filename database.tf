resource "aws_db_instance" "main" {
  identifier             = "mydb"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.small"
  db_name                = "mydb"
  username               = "mijnuser"       # harde waarde
  password               = "SuperVeilig123!" # harde waarde
  multi_az               = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  publicly_accessible    = false

  tags = {
    Name = "main-db"
  }
}
