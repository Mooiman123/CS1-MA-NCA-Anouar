output "vpc_id" {
  value = aws_vpc.main.id
}

output "db_subnet" {
  value = aws_subnet.db.id
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
}
