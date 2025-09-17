output "vpc_id" { value = aws_vpc.main.id }

output "public_subnet" { value = aws_subnet.public.id }
output "app_subnet"    { value = aws_subnet.app.id }
output "db_subnet"     { value = aws_subnet.db.id }
output "monitoring_subnet" { value = aws_subnet.monitoring.id }

output "alb_sg_id"        { value = aws_security_group.alb_sg.id }
output "ec2_sg_id"        { value = aws_security_group.ec2_sg.id }
output "db_sg_id"         { value = aws_security_group.db_sg.id }
output "monitoring_sg_id" { value = aws_security_group.monitoring_sg.id }
