output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_a_subnet" {
  value = aws_subnet.public_a.id
}

output "public_b_subnet" {
  value = aws_subnet.public_b.id
}

output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
