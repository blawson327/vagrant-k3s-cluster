#!/bin/bash

# Get kubectl
#curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /tmp/kubectlvagrant
#chmod +x /tmp/kubectlvagrant

# Get password from master config file
#PASSWORD=$(vagrant ssh kubemaster1 -c "sudo grep password /etc/rancher/k3s/k3s.yaml" | awk -F':' '{print $2}' | sed 's/ //g')
PASSWORD=$(vagrant ssh kubemaster1 -c "sudo grep server /var/lib/rancher/k3s/server/cred/passwd" | awk -F',' '{print $1}' | sed 's/ //g')
CERT_AUTH_DATA=$(vagrant ssh kubemaster1 -c "sudo grep certificate-authority-data /etc/rancher/k3s/k3s.yaml" | awk -F':' '{print $2}' | sed 's/ //g')
CLIENT_CERT_DATA=$(vagrant ssh kubemaster1 -c "sudo grep client-certificate-data /etc/rancher/k3s/k3s.yaml" | awk -F':' '{print $2}' | sed 's/ //g')
CLIENT_KEY_DATA=$(vagrant ssh kubemaster1 -c "sudo grep client-key-data /etc/rancher/k3s/k3s.yaml" | awk -F':' '{print $2}' | sed 's/ //g')

#Create kubectl config
cat << EOF > /tmp/kubectlvagrantconfig.yml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${CERT_AUTH_DATA}
    server: https://10.0.0.30:6443
  name: default
contexts:
- context:
    cluster: default
    user: default
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: default
  user:
    client-certificate-data: ${CLIENT_CERT_DATA}
    client-key-data: ${CLIENT_KEY_DATA}
EOF

# Create temp vars to use kubectl with vagrant
export KUBECONFIG=/tmp/kubectlvagrantconfig.yml
#alias kubectl="/tmp/kubectlvagrant"