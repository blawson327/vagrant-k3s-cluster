#!/bin/bash

TYPE=${1}
VERSION=${2}

MAJORVER=`echo $VERSION|awk -F'.' '{print $1"."$2}'`

echo "Type: ${TYPE}"
echo "Major Version: ${MAJORVER}"
echo "Version: ${VERSION}"


if [[ "${TYPE}" = "traefik" ]]; then
    echo "TRAEFIK"
    # Download and deploy Traefik as a front load balancer
    curl https://github.com/containous/traefik/releases/download/v${VERSION}/traefik_v${VERSION}_linux_amd64.tar.gz -o /tmp/traefik.tar.gz -L
    cd /tmp/
    tar xvfz ./traefik.tar.gz
    #nohup ./traefik --configFile=/tmp/traefikconf/static_conf.toml &> /dev/null&

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

elif [[ "${TYPE}" = "haproxy" ]]; then
    echo "HAPROXY"

    rm -rf /tmp/haproxy-${VERSION}
    if [ ! -e /tmp/haproxy-${VERSION}.tar.gz ]; then
        #curl http://www.haproxy.org/download/${MAJORVER}/src/haproxy-${VERSION}.tar.gz -o /tmp/haproxy-${VERSION}.tar.gz
        curl https://github.com/haproxy/haproxy/archive/refs/tags/v${VERSION}.tar.gz -o /tmp/haproxy-${VERSION}.tar.gz
        cd /tmp
        
        #unzip ./haproxy-${VERSION}.zip
    fi

    if [ ! -d /tmp/haproxy-${VERSION} ]; then
        cd /tmp
        tar xvzf ./haproxy-${VERSION}.tar.gz
    fi

    groupadd -g 321 haproxy
    useradd \
    -g haproxy --no-user-group \
    --home-dir /var/www --no-create-home \
    --shell /usr/sbin/nologin \
    --system --uid 321 haproxy

    apt-get update
    apt-get install -y git ca-certificates gcc libc6-dev liblua5.3-dev libpcre3-dev libssl-dev libsystemd-dev make wget zlib1g-dev
    cd /tmp/haproxy-${VERSION}
    make clean
    make -j $(nproc) TARGET=linux-glibc USE_LUA=1 USE_OPENSSL=1 USE_PCRE=1 USE_ZLIB=1 USE_SYSTEMD=1 USE_PROMEX=1
    make install

    mkdir /etc/haproxy
    chown root:root /etc/haproxy
    cp /tmp/haproxy/*.cfg /etc/haproxy/
    chown root:root /etc/haproxy/*.cfg
    chmod 644 /etc/haproxy/*.cfg

    mkdir /run/haproxy/
    chown haproxy:haproxy /run/haproxy/

    cp /tmp/haproxy.service /etc/systemd/system/haproxy-${VERSION}.service
    chown root:root /etc/systemd/system/haproxy-${VERSION}.service
    chmod 644 /etc/systemd/system/haproxy-${VERSION}.service
    systemctl daemon-reload
    systemctl start haproxy-${VERSION}.service
    systemctl restart haproxy-${VERSION}.service

else
    echo "Unsupported LB"
fi