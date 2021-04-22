#!/bin/bash

# Make alertmanager user
sudo adduser --no-create-home --disabled-login --shell /bin/false --gecos "Alertmanager User" alertmanager

# Make directories and dummy files necessary for alertmanager
sudo mkdir /opt/alertmanager
sudo mkdir /opt/alertmanager/template
sudo mkdir -p /opt/alertmanager/data
sudo touch /opt/alertmanager/alertmanager.yml


sudo chown -R alertmanager:alertmanager /opt/alertmanager
sudo chown -R alertmanager:alertmanager /var/lib/alertmanager

# Download alertmanager and copy utilities to where they should be in the filesystem
#VERSION=0.15.0-rc.0
VERSION=$(curl https://raw.githubusercontent.com/prometheus/alertmanager/master/VERSION)
wget https://github.com/prometheus/alertmanager/releases/download/v${VERSION}/alertmanager-${VERSION}.linux-amd64.tar.gz
tar xvzf alertmanager-${VERSION}.linux-amd64.tar.gz

sudo cp alertmanager-${VERSION}.linux-amd64/alertmanager /usr/local/bin/
sudo cp alertmanager-${VERSION}.linux-amd64/amtool /usr/local/bin/
sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool
sudo chown alertmanager:alertmanager /opt/alertmanager/data

# Populate configuration files
cp /opt/alertmanager-${VERSION}.linux-amd64/alertmanager.yml /opt/alertmanager/alertmanager.yml
echo "[Unit]
Description=AlertManager Server Service
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/alertmanager --config.file /opt/alertmanager/alertmanager.yml --web.external-url=http://0.0.0.0:9093


[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/alertmanager.service


# systemd
sudo systemctl daemon-reload
sudo systemctl enable alertmanager
sudo systemctl start alertmanager

# Installation cleanup
rm alertmanager-${VERSION}.linux-amd64.tar.gz
rm -rf alertmanager-${VERSION}.linux-amd64

sudo systemctl status alertmanager
