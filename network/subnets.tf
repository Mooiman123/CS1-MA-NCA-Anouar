variable "region" {}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = ["10.0.1.0/24","10.0.11.0/24"][count.index]
  availability_zone       = "${var.region}${["a","b"][count.index]}"
  map_public_ip_on_launch = true
  tags = { Name = "public-${count.index}" }
}

resource "aws_subnet" "app" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = ["10.0.2.0/24","10.0.12.0/24"][count.index]
  availability_zone = "${var.region}${["a","b"][count.index]}"
  tags = { Name = "app-${count.index}" }
}

resource "aws_subnet" "db" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = ["10.0.3.0/24","10.0.13.0/24"][count.index]
  availability_zone = "${var.region}${["a","b"][count.index]}"
  tags = { Name = "db-${count.index}" }
}

resource "aws_subnet" "monitoring" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = ["10.0.5.0/28","10.0.15.0/28"][count.index]
  availability_zone = "${var.region}${["a","b"][count.index]}"
  tags = { Name = "monitoring-${count.index}" }
}

output "public_subnet" {
  value = aws_subnet.public[*].id
}

output "app_subnet" {
  value = aws_subnet.app[*].id
}

output "db_subnet" {
  value = aws_subnet.db[*].id
}

output "monitoring_subnet" {
  value = aws_subnet.monitoring[*].id
}
