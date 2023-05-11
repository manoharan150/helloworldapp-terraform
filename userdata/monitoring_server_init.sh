#!/bin/bash
#yum update -y
# install Graphana
cat <<EOF | tee /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

yum install -y grafana

systemctl enable grafana-server
systemctl start grafana-server
systemctl status grafana-server
firewall-cmd --zone=public --add-port=3000/tcp --permanent

#install Prometheus
mkdir /etc/prometheus
mkdir /var/lib/prometheus

curl -LO https://github.com/prometheus/prometheus/releases/download/v2.37.8/prometheus-2.37.8.linux-arm64.tar.gz
tar -xvf prometheus-2.37.8.linux-arm64.tar.gz
mv prometheus-2.37.8.linux-arm64 prometheus-files
cp prometheus-files/prometheus /usr/local/bin/
cp prometheus-files/promtool /usr/local/bin/

cp -r prometheus-files/consoles /etc/prometheus
cp -r prometheus-files/console_libraries /etc/prometheus

cat <<EOF | tee /etc/prometheus/prometheus.yml
global:
 external_labels:
  region: us-central
  monitor: infra
scrape_configs:
 - job_name: prometheus
   scrape_interval: 1m
   static_configs:
    - targets:
       - "localhost:9090"
 - job_name: hello-world
   scrape_interval: 1m
   metrics_path: /metrics-prometheus
   static_configs:
   - targets:
     - "10.0.1.194:8081"
EOF

cat <<EOF | tee  /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
[Service]
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=:9090 \
  --log.level=info
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start prometheus
systemctl status prometheus

firewall-cmd --zone=public --add-port=9090/tcp --permanent
systemctl reload firewalld