# App Servers (2 instances)
resource "aws_instance" "app" {
  count                  = 2
  ami                    = "ami-01592cddfc61fba84"    # harde AMI
  instance_type          = "t3.small"                # harde instance type
  subnet_id              = element([aws_subnet.dmz_a.id, aws_subnet.dmz_b.id], count.index)
  key_name               = "my-key-pair"             # harde key pair
  vpc_security_group_ids = [aws_security_group.dmz_app_sg.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd php php-mysqlnd
              systemctl enable httpd
              systemctl start httpd

              # NODE EXPORTER INSTALLATIE
              cd /tmp
              wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
              tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
              sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
              sudo chmod +x /usr/local/bin/node_exporter

              # systemd service
              sudo cat > /etc/systemd/system/node_exporter.service << 'NODE_SERVICE'
              [Unit]
              Description=Node Exporter
              After=network.target
              [Service]
              Type=simple
              ExecStart=/usr/local/bin/node_exporter
              Restart=on-failure
              [Install]
              WantedBy=multi-user.target
              NODE_SERVICE

              sudo systemctl daemon-reload
              sudo systemctl enable node_exporter
              sudo systemctl start node_exporter

              # PHP applicatie
              echo "<?php
              echo '<h1>Welcome to Web Server ' . strtoupper(substr(gethostname(), -1)) . '</h1>';
              echo '<p>Server: ' . gethostname() . '</p>';
              echo '<p>Server time: ' . date('Y-m-d H:i:s') . '</p>';

              \$link = mysqli_connect('${aws_db_instance.main.endpoint}', 'dbuser', 'SuperVeilig123!');
              if (!\$link) {
                  echo '<p style=\"color: red;\">Database connection failed: ' . mysqli_connect_error() . '</p>';
              } else {
                  echo '<p style=\"color: green;\">✅ Successfully connected to the database server!</p>';
                  \$link->close();
              }
              ?>" > /var/www/html/index.php

              echo "Node Exporter running on port 9100"
              EOF

  tags = {
    Name = "app-${count.index + 1}"
  }

  depends_on = [aws_db_instance.main, aws_nat_gateway.main]
}

# VPN Server
resource "aws_instance" "vpn" {
  ami                         = "ami-01592cddfc61fba84"   # harde AMI
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_a.id
  key_name                    = "my-key-pair"             # harde key pair
  vpc_security_group_ids      = [aws_security_group.vpn_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  tags = {
    Name = "vpn-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y openvpn easy-rsa
              # ... rest van je OpenVPN setup
              EOF
}

# Monitoring Server
resource "aws_instance" "monitoring" {
  ami                         = "ami-01592cddfc61fba84"
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.monitoring.id
  key_name                    = "my-key-pair"
  vpc_security_group_ids      = [aws_security_group.monitoring_sg.id]
  associate_public_ip_address = false

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  user_data = <<-EOF
              #!/bin/bash
              # Internet fix
              echo "nameserver 8.8.8.8" > /etc/resolv.conf
              echo "nameserver 1.1.1.1" >> /etc/resolv.conf
              
              # Update & install Docker
              yum update -y
              yum install -y docker
              systemctl enable docker
              systemctl start docker

              # Prometheus setup
              mkdir -p /opt/prometheus
              cat > /opt/prometheus/prometheus.yml << 'PROMETHEUS_CONFIG'
              global:
                scrape_interval: 15s

              scrape_configs:
                - job_name: 'node_exporter_webservers'
                  static_configs:
                    - targets: ['${aws_instance.app[0].private_ip}:9100', '${aws_instance.app[1].private_ip}:9100']
                      labels:
                        group: 'webservers'

                - job_name: 'prometheus'
                  static_configs:
                    - targets: ['localhost:9090']
              PROMETHEUS_CONFIG

              docker run -d \\
                -p 9090:9090 \\
                -v /opt/prometheus:/etc/prometheus \\
                --name prometheus \\
                prom/prometheus

              # Grafana container met harde admin username/password
              docker run -d \\
                -p 3000:3000 \\
                --name grafana \\
                -e "GF_SECURITY_ADMIN_USER=admin" \\
                -e "GF_SECURITY_ADMIN_PASSWORD=Admin123!" \\
                grafana/grafana

              echo "Monitoring stack geïnstalleerd en gestart!"
              EOF

  tags = {
    Name = "monitoring-server"
  }

  depends_on = [aws_nat_gateway.main]
}
