resource "aws_instance" "prometheus" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = var.monitoring_subnet
  vpc_security_group_ids = [var.monitoring_sg_id]
  tags = { Name = "prometheus-instance" }
}
