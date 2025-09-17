variable "monitoring_subnet" {
  type = list(string)
}
variable "monitoring_sg_id" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "grafana" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type           = "t2.micro"
  subnet_id               = var.monitoring_subnet[0]
  vpc_security_group_ids  = [var.monitoring_sg_id]
  tags = { Name = "grafana" }
}
