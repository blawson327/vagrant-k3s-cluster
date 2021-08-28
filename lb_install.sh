#!/bin/bash
# Download and deploy Traefik as a front load balancer
curl https://github.com/containous/traefik/releases/download/v2.5.1/traefik_v2.5.1_linux_amd64.tar.gz -o /tmp/traefik.tar.gz -L
cd /tmp/
tar xvfz ./traefik.tar.gz

cp /tmp/traefik /usr/local/bin
chown root:root /usr/local/bin/traefik
chmod 755 /usr/local/bin/traefik

setcap 'cap_net_bind_service=+ep' /usr/local/bin/traefik
groupadd -g 321 traefik
useradd \
  -g traefik --no-user-group \
  --home-dir /var/www --no-create-home \
  --shell /usr/sbin/nologin \
  --system --uid 321 traefik

mkdir /etc/traefik
mkdir /etc/traefik/acme
mkdir /etc/traefik/conf
chown -R root:root /etc/traefik
chown -R root:root /etc/traefik/conf
chown -R traefik:traefik /etc/traefik/acme

cp /tmp/traefikconf/* /etc/traefik/conf
chown root:root /etc/traefik/conf/*.toml
chmod 644 /etc/traefik/conf/*.toml

cp /tmp/traefik.service /etc/systemd/system/
chown root:root /etc/systemd/system/traefik.service
chmod 644 /etc/systemd/system/traefik.service
systemctl daemon-reload
systemctl start traefik.service
systemctl restart traefik.service


#nohup ./traefik --configFile=/tmp/traefikconf/static_conf.toml &> /dev/null&
