resource "aws_instance" "dmz" {
  count         = 2
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  subnet_id     = element([var.public_subnet_a, var.public_subnet_b], count.index)
  security_groups = [var.ec2_sg_id]

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y apache2
              systemctl enable apache2
              systemctl start apache2
              EOF

  tags = { Name = "dmz-${count.index + 1}" }
}
