#!/usr/bin/env bash

# Pre-requirements:
# --Java 11 or 17
# --2vCPU (At least 1 CPU core)
# --4GB RAM (at least 2GB)
# --80GB (at least 30GB of free space)

# Update the System
sudo apt update -y
sudo apt install unzip -y

# Install Java
sudo apt install openjdk-17-jdk -y

# Install PostgreSQL 15
sudo apt install curl ca-certificates -y
sudo install -d /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt update
sudo apt install postgresql-15 -y

# Create user & database for SonarQube
sudo -i -u postgres bash <<EOF
createuser sonar
createdb sonar -O sonar
psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'sonar';"
EOF

# Install SonarQube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.6.0.92116.zip
unzip sonarqube-10.6.0.92116.zip
sudo mv sonarqube-10.6.0.92116 /opt/sonarqube

# Create SonarQube user
sudo adduser --system --no-create-home --group --disabled-login sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube

# Change SonarQube config file
echo 'sonar.jdbc.username=sonar' | sudo tee -a /opt/sonarqube/conf/sonar.properties > /dev/null
echo 'sonar.jdbc.password=sonar' | sudo tee -a /opt/sonarqube/conf/sonar.properties > /dev/null
echo 'sonar.jdbc.url=jdbc:postgresql://localhost/sonar' | sudo tee -a /opt/sonarqube/conf/sonar.properties > /dev/null

# Create a Systemd Service for SonarQube
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonarqube
Group=sonarqube
Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

# Reload daemon & start SonarQube service
sudo systemctl daemon-reload
sudo systemctl start sonarqube
sudo systemctl enable sonarqube

# File Descriptors limits
echo "sonarqube   -   nofile   65536" | sudo tee -a /etc/security/limits.conf > /dev/null
echo "sonarqube   -   nproc    4096" | sudo tee -a /etc/security/limits.conf > /dev/null

# Set the virtual memory limit
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Configure Firewall
# yes | sudo ufw enable
# sudo ufw allow OpenSSH
# sudo ufw allow 9000/tcp
# sudo ufw allow 80/tcp
# sudo ufw allow 443/tcp
