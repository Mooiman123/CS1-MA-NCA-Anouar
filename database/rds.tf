resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "case-db-subnet"
  subnet_ids = [var.db_subnet]
}

resource "aws_db_instance" "db" {
  identifier              = "case-db"
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "admin"
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [var.db_sg_id]
  skip_final_snapshot     = true
}
