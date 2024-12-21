#!/usr/bin/env bash

# Update os packages
sudo apt update -y

# Install java8
sudo apt install openjdk-8-jdk -y

# add nexus user
sudo adduser --disabled-login --no-create-home --gecos "" nexus

# Set ulimit
ulimit -n 65536
echo "nexus - nofile 65536" | sudo tee -a /etc/security/limits.d/nexus.conf > /dev/null

# Install nexus
wget https://download.sonatype.com/nexus/3/nexus-3.70.1-02-java8-unix.tar.gz
tar -zxvf nexus-3.70.1-02-java8-unix.tar.gz

# move the extracted file and change owner

mv nexus-3.70.1-02/ /opt/nexus
mv sonatype-work /opt/
chown -R nexus:nexus /opt/nexus /opt/sonatype-work

# Running nexus as the system user "nexus"
# sudo echo 'run_as_user="nexus"' > /opt/nexus/bin/nexus.rc
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/bin/nexus.rc > /dev/null

# Change vmoptions
sudo tee /opt/nexus/bin/nexus.vmoptions > /dev/null <<EOF
-Xms1024m
-Xmx1024m
-XX:MaxDirectMemorySize=1024m
-XX:LogFile=./sonatype-work/nexus3/log/jvm.log
-XX:-OmitStackTraceInFastThrow
-Djava.net.preferIPv4Stack=true
-Dkaraf.home=.
-Dkaraf.base=.
-Dkaraf.etc=etc/karaf
-Djava.util.logging.config.file=/etc/karaf/java.util.logging.properties
-Dkaraf.data=./sonatype-work/nexus3
-Dkaraf.log=./sonatype-work/nexus3/log
-Djava.io.tmpdir=./sonatype-work/nexus3/tmp
EOF

# Configure Nexus as SystemD Service
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
[Unit]
Description=nexus service
After=network.target
[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOF

# opening firewall
# yes | sudo ufw enable
# sudo ufw allow OpenSSH
# sudo ufw allow 8081

# Restart deamon and nexus
sudo systemctl daemon-reload
sudo systemctl start nexus
sudo systemctl enable nexus