output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "grafana_private_ip" {
  value = module.monitoring.grafana_private_ip
}

output "prometheus_private_ip" {
  value = module.monitoring.prometheus_private_ip
}
