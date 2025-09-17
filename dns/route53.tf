resource "aws_route53_zone" "main" {
  name = "zebi.com"
}

resource "aws_route53_record" "lb_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www"
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
