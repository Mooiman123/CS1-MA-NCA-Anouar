output "dns_record" {
  value = aws_route53_record.lb_record.fqdn
}
