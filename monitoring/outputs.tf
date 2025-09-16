output "grafana_private_ip" {
  value = aws_instance.grafana.private_ip
}

output "prometheus_private_ip" {
  value = aws_instance.prometheus.private_ip
}
