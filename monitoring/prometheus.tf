resource "aws_instance" "prometheus" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = var.monitoring_subnet
  vpc_security_group_ids = [var.monitoring_sg_id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io
              systemctl start docker
              docker run -d -p 9090:9090 prom/prometheus
              EOF

  tags = { Name = "prometheus" }
}
