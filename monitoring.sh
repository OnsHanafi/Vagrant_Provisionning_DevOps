# update the system
sudo apt update -y

######### PROMETHUS #########

# Creating Prometheus System Users and Directory
echo "Download Prometheus Binary File"

sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Download Prometheus Binary File
echo "Download Prometheus Binary File"

cd /tmp/
wget https://github.com/prometheus/prometheus/releases/download/v2.46.0/prometheus-2.46.0.linux-amd64.tar.gz
tar -xvf prometheus-2.46.0.linux-amd64.tar.gz

cd prometheus-2.46.0.linux-amd64
sudo mv console* /etc/prometheus
sudo mv prometheus.yml /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus

sudo mv prometheus /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus

# Creating Prometheus Systemd file
echo "Download Node Exporter"

sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

######### Node Exporter #########

# Download Node Exporter
echo "Download Node Exporter"

cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
sudo tar xvfz node_exporter-*.*-amd64.tar.gz
sudo mv node_exporter-*.*-amd64/node_exporter /usr/local/bin/

sudo useradd -rs /bin/false node_exporter

# Creating Node Exporter Systemd service
echo "Creating Node Exporter Systemd service"

sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]

Description=Node Exporter

After=network.target

 

[Service]

User=node_exporter

Group=node_exporter

Type=simple

ExecStart=/usr/local/bin/node_exporter

 

[Install]

WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Install the Blackbox Exporter
echo "Install the Blackbox Exporter"
sudo useradd --no-create-home  --shell /bin/false blackbox_exporter
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.14.0/blackbox_exporter-0.14.0.linux-amd64.tar.gz
tar -xvf blackbox_exporter-0.14.0.linux-amd64.tar.gz
sudo cp blackbox_exporter-0.14.0.linux-amd64/blackbox_exporter /usr/local/bin/blackbox_exporter
sudo chown blackbox_exporter:blackbox_exporter /usr/local/bin/blackbox_exporter
rm -rf blackbox_exporter-0.14.0.linux-amd64*
sudo mkdir /etc/blackbox_exporter
sudo tee /etc/blackbox_exporter/blackbox.yml > /dev/null <<EOF
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      method: GET
  http_post_2xx:
    prober: http
    http:
      method: POST  
  
EOF

sudo chown blackbox_exporter:blackbox_exporter /etc/blackbox_exporter/blackbox.yml
sudo tee /etc/systemd/system/blackbox_exporter.service > /dev/null <<EOF
[Unit]
Description=Blackbox Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=blackbox_exporter
Group=blackbox_exporter
Type=simple
ExecStart=/usr/local/bin/blackbox_exporter --config.file /etc/blackbox_exporter/blackbox.yml

[Install]
WantedBy=multi-user.target   
  
EOF

sudo systemctl daemon-reload
sudo systemctl start blackbox_exporter
sudo systemctl enable blackbox_exporter

# Configure Prometheus targets
echo "ConfigurePrometheus targets"

sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 5s  # Default scrape interval

scrape_configs:
  - job_name: 'Promethus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'Node_Exporter'
    static_configs:
      - targets: ['192.168.1.24:9100']
  - job_name: 'Jenkins'
    metrics_path: /prometheus
    static_configs:
      - targets: ['192.168.1.24:8080']
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]  # Look for a HTTP 200 response.
    static_configs:
      - targets:
        - https://ons-foyer.zapto.org/
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 192.168.1.27:9115
   
  
EOF

sudo systemctl restart prometheus

######### GRAFANA ######### 

# Install Grafana
echo " Install Grafana" 
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
sudo apt update -y
sudo apt install grafana -y
sudo systemctl start grafana-server
sudo systemctl enable grafana-server