resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = { Name = "public-dmz" }
}

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}a"
  tags = { Name = "app-subnet" }
}

resource "aws_subnet" "db" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.region}a"
  tags = { Name = "db-subnet" }
}

resource "aws_subnet" "monitoring" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/28"
  availability_zone = "${var.region}a"
  tags = { Name = "monitoring-subnet" }
}

output "public_subnet" { value = aws_subnet.public.id }
output "app_subnet"    { value = aws_subnet.app.id }
output "db_subnet"     { value = aws_subnet.db.id }
output "monitoring_subnet" { value = aws_subnet.monitoring.id }
