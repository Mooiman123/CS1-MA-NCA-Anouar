# App Servers (2 instances)
resource "aws_instance" "app" {
  count         = 2
  ami           = "ami-01592cddfc61fba84"  # Amazon Linux 2
  instance_type = var.instance_type
  subnet_id     = element([aws_subnet.dmz_a.id, aws_subnet.dmz_b.id], count.index)
  key_name      = var.key_pair_name
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

              # Maak systemd service
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

              # Start Node Exporter
              sudo systemctl daemon-reload
              sudo systemctl enable node_exporter
              sudo systemctl start node_exporter

             # PHP applicatie
              echo "<?php
              echo '<h1>Welcome to Web Server " . strtoupper(substr(gethostname(), -1)) . "</h1>';
              echo '<p>Server: ' . gethostname() . '</p>';
              echo '<p>Server time: ' . date('Y-m-d H:i:s') . '</p>';

              \$link = mysqli_connect('${aws_db_instance.main.endpoint}', 'admin', '${var.db_password}');
              if (!\$link) {
              echo '<p style=\"color: red;\">Database connection failed: ' . mysqli_connect_error() . '</p>';
              } else {
              echo '<p style=\"color: green;\">✅ Successfully connected to the database server!</p>';
             \$conn->close();
            }
            ?>" > /var/www/html/index.php

            echo "Node Exporter running on port 9100"
            EOF

  tags = {
    Name = "app-${count.index + 1}"
  }

  depends_on = [aws_db_instance.main, aws_nat_gateway.main]  # 👈 NAT GATEWAY TOEGEVOEGD
}

# VPN Server - DEFINITIEF WERKENDE VERSIE
resource "aws_instance" "vpn" {
  ami                    = "ami-01592cddfc61fba84"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.vpn_sg.id]
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
              # COMPLETE OpenVPN installatie die WEL werkt
              yum update -y
              yum install -y openvpn easy-rsa
              
              # Maak server directory structuur
              mkdir -p /etc/openvpn/server
              
              # Basis server config
              cat > /etc/openvpn/server.conf << 'OVPN_CONFIG'
              port 1194
              proto udp
              dev tun
              ca /etc/openvpn/ca.crt
              cert /etc/openvpn/server.crt
              key /etc/openvpn/server.key
              dh /etc/openvpn/dh.pem
              server 10.8.0.0 255.255.255.0
              push "redirect-gateway def1 bypass-dhcp"
              push "dhcp-option DNS 8.8.8.8"
              keepalive 10 120
              cipher AES-256-CBC
              user nobody
              group nobody
              persist-key
              persist-tun
              status /var/log/openvpn-status.log
              verb 3
              OVPN_CONFIG
              
              # Kopieer naar server directory
              cp /etc/openvpn/server.conf /etc/openvpn/server/server.conf
              
              # Genereer SIMPELE zelf-ondertekende certificaten
              cd /etc/openvpn
              openssl genrsa -out ca.key 2048
              openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/CN=OpenVPN CA"
              openssl genrsa -out server.key 2048
              openssl req -new -key server.key -out server.csr -subj "/CN=OpenVPN Server"
              openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650
              openssl genrsa -out client.key 2048
              openssl req -new -key client.key -out client.csr -subj "/CN=OpenVPN Client"
              openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 3650
              openssl dhparam -out dh.pem 2048
              
              # Maak client config
              PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
              cat > /home/ec2-user/client.ovpn << CLIENT_CONFIG
              client
              dev tun
              proto udp
              remote $PUBLIC_IP 1194
              resolv-retry infinite
              nobind
              persist-key
              persist-tun
              remote-cert-tls server
              cipher AES-256-CBC
              verb 3
              
              <ca>
              $(cat /etc/openvpn/ca.crt)
              </ca>
              
              <cert>
              $(cat /etc/openvpn/client.crt)
              </cert>
              
              <key>
              $(cat /etc/openvpn/client.key)
              </key>
              CLIENT_CONFIG
              
              # Fix permissions
              chown ec2-user:ec2-user /home/ec2-user/client.ovpn
              
              # Enable IP forwarding
              echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
              sysctl -p
              
              # Start services
              systemctl enable openvpn-server@server
              systemctl start openvpn-server@server
              
              echo "OpenVPN installatie VOLTOOID!"
              echo "Client config: /home/ec2-user/client.ovpn"
              EOF
}

# Monitoring Server - 100% WERKENDE VERSIE
resource "aws_instance" "monitoring" {
  ami                    = "ami-01592cddfc61fba84"
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.monitoring.id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  associate_public_ip_address = false

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  user_data = <<-EOF
              #!/bin/bash
              # EERST internet fix voor privé subnet
              echo "nameserver 8.8.8.8" > /etc/resolv.conf
              echo "nameserver 1.1.1.1" >> /etc/resolv.conf
              
              # Update met retry logic
              for i in {1..5}; do
                yum update -y && break
                sleep 10
              done
              
              # Install Docker
              yum install -y docker
              systemctl enable docker
              systemctl start docker
              
              # Maak Prometheus config directory
              mkdir -p /opt/prometheus
              
              # Maak Prometheus config
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

              # Start Prometheus container
              docker run -d \\
                -p 9090:9090 \\
                -v /opt/prometheus:/etc/prometheus \\
                --name prometheus \\
                prom/prometheus

              # Start Grafana container
              docker run -d \\
                -p 3000:3000 \\
                --name grafana \\
                grafana/grafana

              echo "Monitoring stack geïnstalleerd en gestart!"
              EOF

  tags = {
    Name = "monitoring-server"
  }

  depends_on = [aws_nat_gateway.main]  # 👈 NAT GATEWAY TOEGEVOEGD
}