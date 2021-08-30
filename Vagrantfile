MASTER_COUNT = 3
NODE_COUNT = 3
IMAGE = "ubuntu/focal64"
VIP = "10.0.0.30"
LB = "haproxy" #haproxy or traefik
LB_VERSION = "2.4.0" 

Vagrant.configure("2") do |config|

  config.vm.define "front_lb" do |traefik|
      traefik.vm.box = IMAGE
      traefik.vm.hostname = "traefik"
      traefik.vm.network  :private_network, ip: VIP   
      traefik.vm.provision "file", source: "./scripts/traefik/dynamic_conf.toml", destination: "/tmp/traefikconf/dynamic_conf.toml"
      traefik.vm.provision "file", source: "./scripts/traefik/static_conf.toml", destination: "/tmp/traefikconf/static_conf.toml"
      traefik.vm.provision "file", source: "./scripts/traefik/traefik.service", destination: "/tmp/traefik.service"
      traefik.vm.provision "file", source: "./scripts/haproxy/haproxy.cfg", destination: "/tmp/haproxy/haproxy.cfg"
      traefik.vm.provision "file", source: "./scripts/haproxy/haproxy.service", destination: "/tmp/haproxy.service"
      traefik.vm.provision "file", source: "./scripts/haproxy/haproxy-2.4.0.tar.gz", destination: "/tmp/haproxy-2.4.0.tar.gz"

      traefik.vm.provision "shell", privileged: true,  path: "scripts/lb_install.sh", :args => [LB, LB_VERSION] 
      traefik.vm.network "forwarded_port", guest: 6443, host: 6443
  end

  (1..MASTER_COUNT).each do |i|
    config.vm.define "kubemaster#{i}" do |kubemasters|
      kubemasters.vm.box = IMAGE
      kubemasters.vm.hostname = "kubemaster#{i}"
      kubemasters.vm.network  :private_network, ip: "10.0.0.#{i+10}"
      kubemasters.vm.provision "file", source: "./.ssh/id_rsa.pub", destination: "/tmp/id_rsa.pub"
      kubemasters.vm.provision "file", source: "./.ssh/id_rsa", destination: "/tmp/id_rsa"
      kubemasters.vm.provision "shell", privileged: true,  path: "scripts/master_install.sh"
    end
  end

  (1..NODE_COUNT).each do |i|
    config.vm.define "kubenode#{i}" do |kubenodes|
      kubenodes.vm.box = IMAGE
      kubenodes.vm.hostname = "kubenode#{i}"
      kubenodes.vm.network  :private_network, ip: "10.0.0.#{i+20}"
      kubenodes.vm.provision "file", source: "./.ssh/id_rsa.pub", destination: "/tmp/id_rsa.pub"
      kubenodes.vm.provision "file", source: "./.ssh/id_rsa", destination: "/tmp/id_rsa"
      kubenodes.vm.provision "shell", privileged: true,  path: "scripts/node_install.sh"
    end
  end

  # config.vm.define "front_lb" do |traefik|
  #     traefik.vm.box = IMAGE
  #     traefik.vm.hostname = "traefik"
  #     traefik.vm.network  :private_network, ip: VIP   
  #     traefik.vm.provision "file", source: "./scripts/traefik/dynamic_conf.toml", destination: "/tmp/traefikconf/dynamic_conf.toml"
  #     traefik.vm.provision "file", source: "./scripts/traefik/static_conf.toml", destination: "/tmp/traefikconf/static_conf.toml"
  #     traefik.vm.provision "file", source: "./scripts/traefik/traefik.service", destination: "/tmp/traefik.service"
  #     traefik.vm.provision "shell", privileged: true,  path: "scripts/lb_install.sh"
  #     traefik.vm.network "forwarded_port", guest: 6443, host: 6443
  # end
end