# Gebruik bestaande Route53 Zone
data "aws_route53_zone" "internal" {
  name         = "cs1.local"
  private_zone = true
  vpc_id       = aws_vpc.main.id
}

# DNS record voor Database
resource "aws_route53_record" "db" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "db.cs1.local"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.main.endpoint]
}

# DNS record voor Application Load Balancer
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "app.cs1.local"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.main.dns_name]
}

# DNS record voor Grafana (monitoring)
resource "aws_route53_record" "grafana" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "grafana.cs1.local"
  type    = "A"
  ttl     = 300
  records = [aws_instance.monitoring.private_ip]
}

# DNS record voor Prometheus
resource "aws_route53_record" "prometheus" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "prometheus.cs1.local"
  type    = "A"
  ttl     = 300
  records = [aws_instance.monitoring.private_ip]
}

# DNS record voor VPN server
resource "aws_route53_record" "vpn" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "vpn.cs1.local"
  type    = "A"
  ttl     = 300
  records = [aws_instance.vpn.private_ip]
}

# Outputs voor gemakkelijke toegang
output "internal_dns_zone_id" {
  description = "Route53 Internal Zone ID"
  value       = data.aws_route53_zone.internal.zone_id
}